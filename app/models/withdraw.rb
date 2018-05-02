class Withdraw < ActiveRecord::Base

  STATES           = %i[prepared submitted rejected accepted suspected processing succeed canceled failed].freeze
  COMPLETED_STATES = %i[succeed rejected canceled failed].freeze

  extend Enumerize

  include AASM
  include AASM::Locking
  include Currencible
  include TIDIdentifiable
  include FeeChargeable

  has_paper_trail on: %i[update destroy]

  acts_as_eventable prefix: 'withdraw', on: %i[create update]

  enumerize :aasm_state, in: STATES, scope: true

  belongs_to :member
  belongs_to :account
  has_many :account_versions, as: :modifiable

  delegate :balance, to: :account, prefix: true
  delegate :coin?, :fiat?, to: :currency

  before_validation :fix_precision
  before_validation :set_account

  after_update :sync_update
  after_create :sync_create
  after_destroy :sync_destroy

  validates :amount, :account, :currency, :member, :rid, presence: true

  validates :amount, numericality: { greater_than: 0 }

  validates :sum, presence: true, numericality: { greater_than: 0 }, on: :create
  validates :txid, uniqueness: true, allow_nil: true, on: :update

  validate :ensure_account_balance, on: :create

  scope :completed, -> { where aasm_state: COMPLETED_STATES }
  scope :not_completed, -> { where.not aasm_state: COMPLETED_STATES }

  aasm whiny_transitions: false do
    state :prepared, initial: true
    state :submitted
    state :canceled
    state :accepted
    state :suspected
    state :rejected
    state :processing
    state :succeed
    state :failed

    event :submit do
      transitions from: :prepared, to: :submitted
      after :lock_funds
    end

    event :cancel do
      transitions from: %i[prepared submitted accepted], to: :canceled
      after { unlock_funds unless aasm.from_state == :prepared }
    end

    event :suspect do
      transitions from: :submitted, to: :suspected
      after :unlock_funds
    end

    event :accept do
      transitions from: :submitted, to: :accepted
    end

    event :reject do
      transitions from: %i[submitted accepted], to: :rejected
      after :unlock_funds
    end

    event :process do
      transitions from: :accepted, to: :processing
      after :send_coins!
    end

    event :success do
      transitions from: :processing, to: :succeed
      before %i[unlock_and_sub_funds]
    end

    event :fail do
      transitions from: :processing, to: :failed
      after :unlock_funds
    end
  end

  def cancelable?
    submitted? || accepted?
  end

  def quick?
    sum <= currency.quick_withdraw_limit
  end

  def audit!
    with_lock do
      if account.examine
        accept!
        process! if quick? && currency.coin?
      else
        suspect!
      end
    end
  end

  def as_json_for_event_api
    { tid:             tid,
      uid:             member.uid,
      rid:             rid,
      currency:        currency.code,
      amount:          amount.to_s('F'),
      fee:             fee.to_s('F'),
      state:           aasm_state,
      created_at:      created_at.iso8601,
      updated_at:      updated_at.iso8601,
      completed_at:    done_at&.iso8601,
      blockchain_txid: txid }
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

  def send_coins!
    AMQPQueue.enqueue(:withdraw_coin, id: id) if coin?
  end

  def ensure_account_balance
    if sum.nil? or sum > account.balance
      errors.add :base, -> { I18n.t('activerecord.errors.models.withdraw.account_balance_is_poor') }
    end
  end

  def fix_precision
    if sum && currency.precision
      self.sum = sum.round(currency.precision, BigDecimal::ROUND_DOWN)
    end
  end

  def calc_fee
    self.sum ||= 0.0
    self.fee ||= currency.withdraw_fee
    self.amount = sum - fee
  end

  def set_account
    self.account = member.get_account(currency.code)
  end

  def sync_update
    ::Pusher["private-#{member.sn}"].trigger_async('withdraws', { type: 'update', id: self.id, attributes: changed_attributes })
  end

  def sync_create
    ::Pusher["private-#{member.sn}"].trigger_async('withdraws', { type: 'create', attributes: self.as_json })
  end

  def sync_destroy
    ::Pusher["private-#{member.sn}"].trigger_async('withdraws', { type: 'destroy', id: self.id })
  end

public

  def fiat?
    Withdraws::Fiat === self
  end

  def coin?
    !fiat?
  end
end

# == Schema Information
# Schema version: 20180501141718
#
# Table name: withdraws
#
#  id          :integer          not null, primary key
#  account_id  :integer
#  member_id   :integer
#  currency_id :integer
#  amount      :decimal(32, 16)
#  fee         :decimal(32, 16)
#  created_at  :datetime
#  updated_at  :datetime
#  done_at     :datetime
#  txid        :string(128)
#  aasm_state  :string
#  sum         :decimal(32, 16)  default(0.0), not null
#  type        :string(255)
#  tid         :string(64)       not null
#  rid         :string(64)       not null
#
# Indexes
#
#  index_withdraws_on_currency_id  (currency_id)
#
