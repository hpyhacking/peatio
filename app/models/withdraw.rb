# encoding: UTF-8
# frozen_string_literal: true

class Withdraw < ActiveRecord::Base
  STATES = %i[ prepared
               submitted
               rejected
               accepted
               suspected
               processing
               succeed
               canceled
               failed
               confirming].freeze
  COMPLETED_STATES = %i[succeed rejected canceled failed].freeze

  include AASM
  include AASM::Locking
  include BelongsToCurrency
  include BelongsToMember
  include BelongsToAccount
  include TIDIdentifiable
  include FeeChargeable

  acts_as_eventable prefix: 'withdraw', on: %i[create update]

  before_validation(on: :create) { self.account ||= member&.ac(currency) }
  before_validation { self.completed_at ||= Time.current if completed? }

  validates :rid, :aasm_state, presence: true
  validates :txid, uniqueness: { scope: :currency_id }, if: :txid?
  validates :block_number, allow_blank: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }

  scope :completed, -> { where(aasm_state: COMPLETED_STATES) }

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
    state :confirming

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

    event :dispatch do
      # TODO: add validations that txid and block_number are not blank.
      transitions from: :processing, to: :confirming
    end

    event :success do
      transitions from: :confirming, to: :succeed
      before :unlock_and_sub_funds
    end

    event :fail do
      transitions from: %i[processing confirming], to: :failed
      after :unlock_funds
    end
  end

  def quick?
    sum <= currency.quick_withdraw_limit
  end

  def audit!
    with_lock do
      accept!
      process! if quick? && currency.coin?
    end
  end

  def fiat?
    Withdraws::Fiat === self
  end

  def coin?
    !fiat?
  end

  def completed?
    aasm_state.in?(COMPLETED_STATES.map(&:to_s))
  end

  def as_json_for_event_api
    { tid:             tid,
      uid:             member.uid,
      rid:             rid,
      currency:        currency_id,
      amount:          amount.to_s('F'),
      fee:             fee.to_s('F'),
      state:           aasm_state,
      created_at:      created_at.iso8601,
      updated_at:      updated_at.iso8601,
      completed_at:    completed_at&.iso8601,
      blockchain_txid: txid }
  end

private

  def lock_funds
    account.lock_funds(sum)
  end

  def unlock_funds
    account.unlock_funds(sum)
  end

  def unlock_and_sub_funds
    account.unlock_and_sub_funds(sum)
  end

  def send_coins!
    AMQPQueue.enqueue(:withdraw_coin, id: id) if coin?
  end
end

# == Schema Information
# Schema version: 20180925123806
#
# Table name: withdraws
#
#  id           :integer          not null, primary key
#  account_id   :integer          not null
#  member_id    :integer          not null
#  currency_id  :string(10)       not null
#  amount       :decimal(32, 16)  not null
#  fee          :decimal(32, 16)  not null
#  txid         :string(128)
#  aasm_state   :string(30)       not null
#  block_number :integer
#  sum          :decimal(32, 16)  not null
#  type         :string(30)       not null
#  tid          :string(64)       not null
#  rid          :string(95)       not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  completed_at :datetime
#
# Indexes
#
#  index_withdraws_on_aasm_state            (aasm_state)
#  index_withdraws_on_account_id            (account_id)
#  index_withdraws_on_currency_id           (currency_id)
#  index_withdraws_on_currency_id_and_txid  (currency_id,txid) UNIQUE
#  index_withdraws_on_member_id             (member_id)
#  index_withdraws_on_tid                   (tid)
#  index_withdraws_on_type                  (type)
#
