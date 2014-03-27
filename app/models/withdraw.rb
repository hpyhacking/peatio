class Withdraw < ActiveRecord::Base
  extend ActiveHash::Associations::ActiveRecordExtensions

  include AASM
  include AASM::Locking
  include Concerns::Withdraws::BTC
  include Concerns::Withdraws::CNY

  has_paper_trail on: [:update, :destroy]

  STATES = {
    submitting: 10,
    submitted: 100,
    rejected: 110,
    accepted: 210,
    suspect: 220,
    processing: 300,
    coin_ready: 400,
    coin_done: 410,
    done: 500,
    canceled: 0,
    almost_done: 499,
    failed: 510
  }

  COMPLETED_STATES = [:done, :rejected, :canceled, :almost_done, :failed]

  extend Enumerize
  enumerize :state, in: STATES, scope: true
  enumerize :currency, in: Currency.codes, scope: true

  belongs_to :member
  belongs_to :account
  has_many :account_versions, :as => :modifiable
  attr_accessor :save_fund_source

  before_validation :fix_fee
  after_create :create_fund_source, if: :save_fund_source?
  after_create :generate_sn
  after_update :bust_last_done_cache, if: :state_changed_to_done

  validates :channel_id, :fund_uid, :fund_extra, :amount, :fee,
    :account, :currency, :member, presence: true

  validates :fee, numericality: {greater_than_or_equal_to: 0}
  validates :amount, numericality: {greater_than: 0}

  validates :sum, presence: true, on: :create
  validates :sum, numericality: {greater_than: 0}, on: :create
  validates :txid, uniqueness: true, allow_nil: true, on: :update

  validate :ensure_account_balance, on: :create

  scope :completed, -> { where('aasm_state in (?) or state in (?)',
                               COMPLETED_STATES, STATES.slice(*COMPLETED_STATES).values) }
  scope :not_completed, -> { where('aasm_state not in (?) or state not in (?)',
                               COMPLETED_STATES, STATES.slice(*COMPLETED_STATES).values) }

  alias_method :_old_state, :state

  def state
    _old_state || Enumerize::Value.new(Withdraw.state, aasm_state)
  end

  def channel
    WithdrawChannel.find(channel_id)
  end

  def currency_symbol
    case channel.currency
    when 'btc' then 'B⃦'
    when 'cny' then '¥'
    else ''
    end
  end

  def coin?
    ['btc'].include? currency
  end

  def fiat?
    !coin?
  end

  def examine
    Resque.enqueue(Job::Examine, self.id) if submitted?
  end

  def position_in_queue
    last_done = Rails.cache.fetch(last_completed_withdraw_cache_key) do
      Withdraw.completed.where(channel_id: channel_id).maximum(:id)
    end

    self.class.where("id > ? AND id <= ?", (last_done || 0), id).
      where(channel_id: channel_id).
      count
  end

  alias_attribute :withdraw_id, :sn

  def generate_sn
    id_part = sprintf '%04d', id
    date_part = created_at.localtime.strftime('%y%m%d%H%M')
    self.sn = "#{date_part}#{id_part}"
    update_column(:sn, sn)
  end

  aasm do
    state :submitting, initial: true
    state :submitted, after_commit: :examine
    state :canceled, after_commit: :send_email
    state :accepted
    state :suspect, after_commit: :send_email
    state :rejected, after_commit: :send_email
    state :processing, after_commit: :send_coins!
    state :almost_done
    state :done, after_commit: :send_email
    state :failed, after_commit: :send_email

    event :submit do
      transitions from: :submitting, to: :submitted
      after do
        lock_funds
      end
    end

    event :cancel do
      transitions from: [:submitting, :submitted, :accepted], to: :canceled
      before do
        unlock_funds unless submitting?
      end
    end

    event :mark_suspect do
      transitions from: :submitted, to: :suspect
    end

    event :accept do
      transitions from: :submitted, to: :accepted
    end

    event :reject do
      transitions from: :accepted, to: :rejected
      after :unlock_funds
    end

    event :process do
      transitions from: :accepted, to: :processing
    end

    event :call_rpc do
      transitions from: :processing, to: :almost_done
    end

    event :succeed do
      transitions from: [:processing, :almost_done], to: :done

      before [:set_txid, :unlock_and_sub_funds]
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end

  def cancelable?
    submitting? or submitted? or accepted?
  end

  private

  def lock_funds
    account.lock!
    account.lock_funds sum, reason: Account::WITHDRAW_LOCK, ref: self
  end

  def unlock_funds
    account.lock!
    account.unlock_funds sum, reason: Account::WITHDRAW_UNLOCK, ref: self
  end

  def unlock_and_sub_funds
    account.lock!
    account.unlock_and_sub_funds sum, locked: sum, fee: fee, reason: Account::WITHDRAW, ref: self
  end

  def set_txid
    self.txid = @sn unless coin?
  end

  def send_email
    WithdrawMailer.withdraw_state(self.id).deliver
  end

  def send_coins!
    Resque.enqueue(Job::Coin, self.id) if coin?
  end

  def last_completed_withdraw_cache_key
    "last_completed_withdraw_id_for_#{channel.key}"
  end

  def ensure_account_balance
    if self.sum > account.balance
      errors.add(:sum, :poor)
    end
  end

  def fix_fee
    if self.respond_to? valid_method = "_valid_#{channel.key}_sum"
      error = self.instance_eval(valid_method)
      self.errors.add('sum', "#{channel.key}_#{error}".to_sym) if error
    end

    if self.respond_to? fee_method = "_fix_#{channel.key}_fee"
      self.instance_eval(fee_method)
    end

    # withdraw fee inner cost
    self.fee ||= 0.0
    self.amount = (self.sum - self.fee)
  end

  def state_changed_to_done
    aasm_state_changed? && COMPLETED_STATES.include?(state.to_sym)
  end

  def bust_last_done_cache
    Rails.cache.delete(last_completed_withdraw_cache_key)
  end

  def save_fund_source?
    @save_fund_source == '1'
  end

  def create_fund_source
    FundSource.create \
      uid: fund_uid,
      extra: fund_extra,
      is_locked: false
  end
end
