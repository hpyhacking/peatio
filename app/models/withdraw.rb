class Withdraw < ActiveRecord::Base
  STATES = [:submitting, :submitted, :rejected, :accepted, :suspect, :processing,
            :done, :canceled, :failed]
  COMPLETED_STATES = [:done, :rejected, :canceled, :failed]

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
  delegate :coin?, :fiat?, to: :currency_obj

  before_validation :fix_precision
  before_validation :calc_fee
  before_validation :set_account
  after_create :generate_sn

  after_update :sync_update
  after_create :sync_create
  after_destroy :sync_destroy

  validates_with WithdrawBlacklistValidator

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
    state :submitted
    state :canceled
    state :accepted
    state :suspect
    state :rejected
    state :processing
    state :done
    state :failed

    event :submit, after_commit: :send_email do
      transitions from: :submitting, to: :submitted
      after do
        lock_funds
      end
    end

    event :cancel, after_commit: :send_email do
      transitions from: [:submitting, :submitted, :accepted], to: :canceled
      after do
        after_cancel
      end
    end

    event :mark_suspect, after_commit: :send_email do
      transitions from: :submitted, to: :suspect
    end

    event :accept do
      transitions from: :submitted, to: :accepted
    end

    event :reject, after_commit: :send_email do
      transitions from: [:submitted, :accepted, :processing], to: :rejected
      after :unlock_funds
    end

    event :process, after_commit: %i[ send_coins! send_email ] do
      transitions from: :accepted, to: :processing
    end

    event :succeed, after_commit: :send_email do
      transitions from: :processing, to: :done

      before [:set_txid, :unlock_and_sub_funds]
    end

    event :fail, after_commit: :send_email do
      transitions from: :processing, to: :failed
      after :unlock_funds
    end
  end

  def cancelable?
    submitting? or submitted? or accepted?
  end

  def quick?
    sum <= currency_obj.quick_withdraw_max
  end

  def audit!
    with_lock do
      if account.examine
        accept
        process if quick?
      else
        mark_suspect
      end

      save!
    end

    # FIXME: Unfortunately AASM doesn't fire after_commit
    # callback (don't be confused with ActiveRecord's after_commit).
    # This probably was broken after upgrade of Rails & gems.
    # The fix is to manually invoke #send_coins! and #send_email.
    # NOTE: These calls should be out of transaction so fast workers
    # would not start processing data before it was committed to DB.
    send_coins! if processing?
    send_email
  end

  private

  def after_cancel
    unlock_funds unless aasm.from_state == :submitting
  end

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
    case aasm_state
    when 'submitted'
      WithdrawMailer.submitted(self.id).deliver
    when 'processing'
      WithdrawMailer.processing(self.id).deliver
    when 'done'
      WithdrawMailer.done(self.id).deliver
    else
      WithdrawMailer.withdraw_state(self.id).deliver
    end
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
    if sum && currency_obj.precision
      self.sum = sum.round(currency_obj.precision, BigDecimal::ROUND_DOWN)
    end
  end

  def calc_fee
    self.sum ||= 0.0
    # You can set fee for each currency in withdraw_channels.yml.
    self.fee ||= WithdrawChannel.find_by_currency(currency).fee
    self.amount = sum - fee
  end

  def set_account
    self.account = member.get_account(currency)
  end

  def self.resource_name
    name.demodulize.underscore.pluralize
  end

  def sync_update
    ::Pusher["private-#{member.sn}"].trigger_async('withdraws', { type: 'update', id: self.id, attributes: self.changes_attributes_as_json })
  end

  def sync_create
    ::Pusher["private-#{member.sn}"].trigger_async('withdraws', { type: 'create', attributes: self.as_json })
  end

  def sync_destroy
    ::Pusher["private-#{member.sn}"].trigger_async('withdraws', { type: 'destroy', id: self.id })
  end


end

# == Schema Information
# Schema version: 20180215144645
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
#  aasm_state :string
#  sum        :decimal(32, 16)  default(0.0), not null
#  type       :string(255)
#
