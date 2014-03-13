class Withdraw < ActiveRecord::Base
  include AASM
  include Concerns::Withdraws::Bank
  include Concerns::Withdraws::Satoshi

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
  enumerize :address_type, in: WithdrawChannel.enumerize
  enumerize :currency, in: Currency.codes, scope: true

  belongs_to :member
  belongs_to :account
  has_many :account_versions, :as => :modifiable
  attr_accessor :withdraw_address_id

  before_validation :populate_fields_from_address, :fix_fee
  after_create :generate_sn
  after_update :bust_last_done_cache, if: :state_changed_to_done

  validates :address_type, :address, :address_label,
    :amount, :fee, :account, :currency, :member, presence: true

  validates :fee, numericality: {greater_than_or_equal_to: 0}
  validates :amount, numericality: {greater_than: 0}

  validates :sum, presence: true, on: :create
  validates :sum, numericality: {greater_than: 0}, on: :create
  validates :tx_id, uniqueness: true, allow_nil: true, on: :update

  validate :ensure_account_balance, on: :create

  scope :completed, -> { where('aasm_state in (?) or state in (?)',
                               COMPLETED_STATES, STATES.slice(*COMPLETED_STATES).values) }
  scope :not_completed, -> { where('aasm_state not in (?) or state not in (?)',
                               COMPLETED_STATES, STATES.slice(*COMPLETED_STATES).values) }

  alias_method :_old_state, :state

  def state
    _old_state || Enumerize::Value.new(Withdraw.state, aasm_state)
  end

  def coin?
    address_type.try(:satoshi?) or address_type.try(:protoshares?)
  end

  def examine
    Resque.enqueue(Job::Examine, self.id) if submitted?
  end

  def position_in_queue
    last_done = Rails.cache.fetch(last_completed_withdraw_cache_key) do
      Withdraw.completed.where(address_type: address_type.value).maximum(:id)
    end

    self.class.where("id > ? AND id <= ?", (last_done || 0), id).
      where(address_type: address_type.value).
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
    state :submitted, after_enter: :lock_funds, after_commit: [:send_withdraw_confirm_email, :examine]
    state :canceled
    state :accepted
    state :suspect
    state :rejected
    state :processing
    state :almost_done
    state :done
    state :failed

    event :submit do
      transitions from: :submitting, to: :submitted
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
      after do
        send_coins! if coin?
      end
    end

    event :call_rpc do
      transitions from: :processing, to: :almost_done
    end

    event :succeed do
      transitions from: [:processing, :almost_done], to: :done

      before [:set_tx_id, :unlock_and_sub_funds]
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end

  private

  def lock_funds
    account.lock_funds sum, reason: Account::WITHDRAW_LOCK, ref: self
  end

  def unlock_funds
    account.unlock_funds sum, reason: Account::WITHDRAW_UNLOCK, ref: self
  end

  def unlock_and_sub_funds
    account.unlock_and_sub_funds sum, locked: sum, fee: fee, reason: Account::WITHDRAW, ref: self
  end

  def set_tx_id
    @tx_id = @sn unless coin?
  end

  def send_withdraw_confirm_email
    puts 'Sending withdraw confirm email!'
  end

  def send_coins!
    Resque.enqueue(Job::Coin, self.id) if coin?
  end

  def last_completed_withdraw_cache_key
    "last_completed_withdraw_id_for_#{address_type}"
  end

  def ensure_account_balance
    unless account
      errors.add(:withdraw_address_id, :blank) and return
    end

    if self.sum > account.balance
      errors.add(:sum, :poor)
    end
  end

  def populate_fields_from_address
    withdraw_address = WithdrawAddress.where(id: withdraw_address_id).first
    return if withdraw_address.nil?

    account = withdraw_address.account
    return if account.nil?

    self.account_id = account.id
    self.currency = account.currency
    self.address = withdraw_address.address
    self.address_type = withdraw_address.category
    self.address_label = withdraw_address.label
  end

  def fix_fee
    if self.respond_to? valid_method = "_valid_#{self.address_type}_sum"
      error = self.instance_eval(valid_method)
      self.errors.add('sum', "#{self.address_type}_#{error}".to_sym) if error
    end

    if self.respond_to? fee_method = "_fix_#{self.address_type}_fee"
      self.instance_eval(fee_method)
    end

    # withdraw fee inner cost
    self.fee ||= 0.0
    self.amount = (self.sum - self.fee)
  end

  def state_changed_to_done
    state_changed? && COMPLETED_STATES.include?(state.to_sym)
  end

  def bust_last_done_cache
    Rails.cache.delete(last_completed_withdraw_cache_key)
  end


end
