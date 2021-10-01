# encoding: UTF-8
# frozen_string_literal: true

class Withdraw < ApplicationRecord
  STATES = %i[ prepared
               rejected
               accepted
               skipped
               processing
               succeed
               canceled
               failed
               errored
               confirming
               under_review].freeze
  COMPLETED_STATES = %i[succeed rejected canceled failed].freeze
  SUCCEED_PROCESSING_STATES = %i[prepared accepted skipped processing errored confirming succeed under_review].freeze

  include AASM
  include AASM::Locking
  include TIDIdentifiable
  include FeeChargeable

  extend Enumerize

  serialize :error, JSON unless Rails.configuration.database_support_json
  serialize :metadata, JSON unless Rails.configuration.database_support_json

  TRANSFER_TYPES = { fiat: 100, crypto: 200 }

  belongs_to :currency, required: true
  belongs_to :member, required: true
  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key, required: true
  belongs_to :blockchain_currency, class_name: 'BlockchainCurrency', foreign_key: %i[blockchain_key currency_id], primary_key: %i[blockchain_key currency_id]

  # Optional beneficiary association gives ability to support both in-peatio
  # beneficiaries and managed by third party application.
  belongs_to :beneficiary, optional: true

  acts_as_eventable prefix: 'withdraw', on: %i[create update]

  after_initialize :initialize_defaults, if: :new_record?
  before_validation(on: :create) { self.rid ||= beneficiary.rid if beneficiary.present? }
  before_validation { self.completed_at ||= Time.current if completed? }
  before_validation { self.transfer_type ||= currency.coin? ? 'crypto' : 'fiat' }

  validates :rid, :aasm_state, presence: true
  validates :txid, uniqueness: { scope: :currency_id }, if: :txid?
  validates :block_number, allow_blank: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :sum,
            presence: true,
            numericality: { greater_than_or_equal_to: ->(withdraw) { withdraw.blockchain_currency.min_withdraw_amount }},
            on: :create

  validates :blockchain_key,
            inclusion: { in: ->(_) { Blockchain.pluck(:key).map(&:to_s) } }

  validate do
    errors.add(:beneficiary, 'not active') if beneficiary.present? && !beneficiary.active? && !aasm_state.to_sym.in?(COMPLETED_STATES)
  end

  scope :completed, -> { where(aasm_state: COMPLETED_STATES) }
  scope :succeed_processing, -> { where(aasm_state: SUCCEED_PROCESSING_STATES) }
  scope :last_24_hours, -> { where('created_at > ?', 24.hour.ago) }
  scope :last_1_month, -> { where('created_at > ?', 1.month.ago) }

  aasm whiny_transitions: false do
    state :prepared, initial: true
    state :canceled
    state :accepted
    state :skipped
    state :to_reject
    state :rejected
    state :processing
    state :under_review
    state :succeed
    state :failed
    state :errored
    state :confirming

    event :accept do
      transitions from: :prepared, to: :accepted
      after do
        lock_funds
        record_submit_operations!
      end
      after_commit do
        # auto process withdrawal if sum less than limits and WITHDRAW_ADMIN_APPROVE env set to false (not set)
        process! if verify_limits && ENV.false?('WITHDRAW_ADMIN_APPROVE') && currency.coin?
      end
    end

    event :cancel do
      transitions from: %i[prepared accepted], to: :canceled
      after do
        unless aasm.from_state == :prepared
          unlock_funds
          record_cancel_operations!
        end
      end
    end

    event :reject do
      transitions from: %i[to_reject accepted confirming under_review], to: :rejected
      after do
        unlock_funds
        record_cancel_operations!
      end
    end

    event :process do
      transitions from: %i[accepted skipped errored], to: :processing
      after :send_coins!
    end

    event :load do
      transitions from: :accepted, to: :confirming do
        # Load event is available only for coin withdrawals.
        guard do
          currency.coin? && txid?
        end
      end
      after_commit do
        tx = blockchain_currency.blockchain_api.fetch_transaction(self)
        if tx.present?
          success! if tx.status.success?
        end
      end
    end

    event :review do
      transitions from: :processing, to: :under_review
    end

    event :dispatch do
      transitions from: %i[processing under_review], to: :confirming do
        # Validate txid presence on coin withdrawal dispatch.
        guard do
          currency.fiat? || txid?
        end
      end
    end

    event :success do
      transitions from: %i[confirming errored under_review], to: :succeed do
        guard do
          currency.fiat? || txid?
        end
        after do
          unlock_and_sub_funds
          record_complete_operations!
        end
      end
    end

    event :skip do
      transitions from: :processing, to: :skipped
    end

    event :fail do
      transitions from: %i[processing confirming skipped errored under_review], to: :failed
      after do
        unlock_funds
        record_cancel_operations!
      end
    end

    event :err do
      transitions from: :processing, to: :errored, after: :add_error
    end
  end

  delegate :protocol, :warning, to: :blockchain

  class << self
    def sum_query
      'SELECT sum(w.sum * c.price) as sum FROM withdraws as w ' \
      'INNER JOIN currencies as c ON c.id=w.currency_id ' \
      'where w.member_id = ? AND w.aasm_state IN (?) AND w.created_at > ?;'
    end

    def sanitize_execute_sum_queries(member_id)
      squery_24h = ActiveRecord::Base.sanitize_sql_for_conditions([sum_query, member_id, SUCCEED_PROCESSING_STATES, 24.hours.ago])
      squery_1m = ActiveRecord::Base.sanitize_sql_for_conditions([sum_query, member_id, SUCCEED_PROCESSING_STATES, 1.month.ago])
      sum_withdraws_24_hours = ActiveRecord::Base.connection.exec_query(squery_24h).to_hash.first['sum'].to_d
      sum_withdraws_1_month = ActiveRecord::Base.connection.exec_query(squery_1m).to_hash.first['sum'].to_d
      [sum_withdraws_24_hours, sum_withdraws_1_month]
    end
  end

  def initialize_defaults
    self.metadata = {} if metadata.blank?
  end

  def account
    member&.get_account(currency)
  end

  def add_error(e)
    if error.blank?
      update!(error: [{ class: e.class.to_s, message: e.message }])
    else
      update!(error: error << { class: e.class.to_s, message: e.message })
    end
  end

  def verify_limits
    limits = WithdrawLimit.for(kyc_level: member.level, group: member.group)

    # If there are no limits in DB or current user withdraw limit
    # has 0.0 for 24 hour and 1 mounth it will skip this checks
    return true if limits.limit_24_hour.zero? && limits.limit_1_month.zero?

    # Withdraw limits in USD and withdraw sum in currency.
    # Convert withdraw sums with price from the currency model.
    sum_24_hours, sum_1_month = Withdraw.sanitize_execute_sum_queries(member_id)

    sum_24_hours + sum * currency.get_price <= limits.limit_24_hour &&
      sum_1_month + sum * currency.get_price <= limits.limit_1_month
  end

  def blockchain_api
    blockchain_currency.blockchain_api
  end

  def confirmations
    return 0 if block_number.blank?
    return blockchain.processed_height - block_number if (blockchain.processed_height - block_number) >= 0
    'N/A'
  rescue StandardError => e
    report_exception(e)
    'N/A'
  end

  def completed?
    aasm_state.in?(COMPLETED_STATES.map(&:to_s))
  end

  def as_json_for_event_api
    { tid:             tid,
      user:            { uid: member.uid, email: member.email },
      uid:             member.uid,
      rid:             rid,
      currency:        currency_id,
      amount:          amount.to_s('F'),
      fee:             fee.to_s('F'),
      state:           aasm_state,
      created_at:      created_at.iso8601,
      updated_at:      updated_at.iso8601,
      completed_at:    completed_at&.iso8601,
      blockchain_txid: txid,
      explorer_address: blockchain&.explorer_address,
      explorer_transaction: blockchain&.explorer_transaction }
  end

  private

  # @deprecated
  def lock_funds
    account.lock_funds(sum)
  end

  # @deprecated
  def unlock_funds
    account.unlock_funds(sum)
  end

  # @deprecated
  def unlock_and_sub_funds
    account.unlock_and_sub_funds(sum)
  end

  def record_submit_operations!
    transaction do
      # Debit main fiat/crypto Liability account.
      # Credit locked fiat/crypto Liability account.
      Operations::Liability.transfer!(
        amount:     sum,
        currency:   currency,
        reference:  self,
        from_kind:  :main,
        to_kind:    :locked,
        member_id:  member_id
      )
    end
  end

  def record_cancel_operations!
    transaction do
      # Debit locked fiat/crypto Liability account.
      # Credit main fiat/crypto Liability account.
      Operations::Liability.transfer!(
        amount:     sum,
        currency:   currency,
        reference:  self,
        from_kind:  :locked,
        to_kind:    :main,
        member_id:  member_id
      )
    end
  end

  def record_complete_operations!
    transaction do
      # Debit locked fiat/crypto Liability account.
      Operations::Liability.debit!(
        amount:     sum,
        currency:   currency,
        reference:  self,
        kind:       :locked,
        member_id:  member_id
      )

      # Credit main fiat/crypto Revenue account.
      # NOTE: Credit amount = fee.
      Operations::Revenue.credit!(
        amount:     fee,
        currency:   currency,
        reference:  self,
        member_id:  member_id
      )

      # Debit main fiat/crypto Asset account.
      # NOTE: Debit amount = sum - fee.
      Operations::Asset.debit!(
        amount:     amount,
        currency:   currency,
        reference:  self
      )
    end
  end

  def send_coins!
    AMQP::Queue.enqueue(:withdraw_coin, id: id) if currency.coin?
  end
end

# == Schema Information
# Schema version: 20211001083227
#
# Table name: withdraws
#
#  id             :bigint           not null, primary key
#  member_id      :bigint           not null
#  beneficiary_id :bigint
#  currency_id    :string(10)       not null
#  blockchain_key :string(255)      not null
#  amount         :decimal(32, 16)  not null
#  fee            :decimal(32, 16)  not null
#  txid           :string(128)
#  aasm_state     :string(30)       not null
#  block_number   :integer
#  sum            :decimal(32, 16)  not null
#  type           :string(30)       not null
#  transfer_type  :integer
#  tid            :string(64)       not null
#  rid            :string(105)      not null
#  remote_id      :string(255)
#  note           :string(256)
#  metadata       :json
#  error          :json
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  completed_at   :datetime
#
# Indexes
#
#  index_withdraws_on_aasm_state            (aasm_state)
#  index_withdraws_on_currency_id           (currency_id)
#  index_withdraws_on_currency_id_and_txid  (currency_id,txid) UNIQUE
#  index_withdraws_on_member_id             (member_id)
#  index_withdraws_on_tid                   (tid)
#  index_withdraws_on_type                  (type)
#
