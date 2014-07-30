# == Schema Information
#
# Table name: withdraws
#
#  id         :integer          not null, primary key
#  sn         :string(255)
#  account_id :integer
#  member_id  :integer
#  currency   :integer
#  amount     :decimal(32, 16)
#  fee        :decimal(32, 16)
#  fund_uid   :string(255)
#  fund_extra :string(255)
#  created_at :datetime
#  updated_at :datetime
#  done_at    :datetime
#  txid       :string(255)
#  aasm_state :string(255)
#  sum        :decimal(32, 16)
#  type       :string(255)
#

class Withdraw < ActiveRecord::Base
  STATES = [:submitting, :submitted, :rejected, :accepted, :suspect, :processing,
            :coin_ready, :coin_done, :done, :canceled, :almost_done, :failed]
  COMPLETED_STATES = [:done, :rejected, :canceled, :almost_done, :failed]

  extend Enumerize

  include AASM
  include AASM::Locking
  include Currencible

  has_paper_trail on: [:update, :destroy]

  enumerize :aasm_state, in: STATES, scope: true

  belongs_to :member
  belongs_to :account
  has_many :account_versions, as: :modifiable

  delegate :balance, to: :account, prefix: true
  delegate :key_text, to: :channel, prefix: true
  delegate :id, to: :channel, prefix: true
  delegate :name, to: :member, prefix: true
  delegate :coin?, to: :currency_obj

  before_validation :calc_fee
  before_validation :set_account
  after_create :generate_sn
  after_update :bust_last_done_cache, if: :state_changed_to_done

  validates :fund_uid, :amount, :fee, :account, :currency, :member, presence: true

  validates :fee, numericality: {greater_than_or_equal_to: 0}
  validates :amount, numericality: {greater_than: 0}

  validates :sum, presence: true, numericality: {greater_than: 0}, on: :create
  validates :txid, uniqueness: true, allow_nil: true, on: :update

  validate :ensure_account_balance, on: :create

  scope :completed, -> { where aasm_state: COMPLETED_STATES }
  scope :not_completed, -> { where.not aasm_state: COMPLETED_STATES }

  def self.channel
    WithdrawChannel.find_by_key(name.demodulize.underscore)
  end

  def channel
    self.class.channel
  end

  def channel_name
    channel.key
  end

  def fiat?
    !coin?
  end

  def audit
    AMQPQueue.enqueue(:withdraw_audit, id: id) if submitted?
  end

  def position_in_queue
    last_done = Rails.cache.fetch(last_completed_withdraw_cache_key) do
      self.class.completed.maximum(:id)
    end

    self.class.where("id > ? AND id <= ?", (last_done || 0), id).count
  end

  alias_attribute :withdraw_id, :sn
  alias_attribute :full_name, :member_name

  def generate_sn
    id_part = sprintf '%04d', id
    date_part = created_at.localtime.strftime('%y%m%d%H%M')
    self.sn = "#{date_part}#{id_part}"
    update_column(:sn, sn)
  end

  aasm :whiny_transitions => false do
    state :submitting,  initial: true
    state :submitted,   after_commit: :audit
    state :canceled,    after_commit: :send_email
    state :accepted
    state :suspect,     after_commit: :send_email
    state :rejected,    after_commit: :send_email
    state :processing,  after_commit: :send_coins!
    state :almost_done
    state :done,        after_commit: :send_email
    state :failed,      after_commit: :send_email

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
      transitions from: [:submitted, :accepted, :processing], to: :rejected
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
    AMQPQueue.enqueue(:withdraw_coin, id: id) if coin?
  end

  def last_completed_withdraw_cache_key
    "last_completed_withdraw_id_for_#{channel.key}"
  end

  def ensure_account_balance
    if sum.nil? or sum > account.balance
      errors.add(:sum, :poor)
    end
  end

  def calc_fee
    if respond_to?(:set_fee)
      set_fee
    end

    self.sum ||= 0.0
    self.fee ||= 0.0
    self.amount = sum - fee
  end

  def set_account
    self.account = member.get_account(currency)
  end

  def state_changed_to_done
    aasm_state_changed? && COMPLETED_STATES.include?(aasm_state.to_sym)
  end

  def bust_last_done_cache
    Rails.cache.delete(last_completed_withdraw_cache_key)
  end

  def self.resource_name
    name.demodulize.underscore.pluralize
  end
end
