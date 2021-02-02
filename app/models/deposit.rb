# encoding: UTF-8
# frozen_string_literal: true

class Deposit < ApplicationRecord
  STATES = %i[submitted canceled rejected accepted collected skipped processing fee_processing].freeze

  serialize :spread, Array
  serialize :from_addresses, Array

  include AASM
  include AASM::Locking
  include TIDIdentifiable
  include FeeChargeable

  extend Enumerize
  TRANSFER_TYPES = { fiat: 100, crypto: 200 }

  belongs_to :currency, required: true
  belongs_to :member, required: true

  acts_as_eventable prefix: 'deposit', on: %i[create update]

  validates :tid, presence: true, uniqueness: { case_sensitive: false }
  validates :aasm_state, :type, presence: true
  validates :completed_at, presence: { if: :completed? }
  validates :block_number, allow_blank: true, numericality: { greater_than_or_equal_to: 0, only_integer: true }
  validates :amount,
            numericality: {
              greater_than_or_equal_to:
                -> (deposit){ deposit.currency.min_deposit_amount }
            }

  scope :recent, -> { order(id: :desc) }

  before_validation { self.completed_at ||= Time.current if completed? }
  before_validation { self.transfer_type ||= currency.coin? ? 'crypto' : 'fiat' }

  aasm whiny_transitions: false do
    state :submitted, initial: true
    state :canceled
    state :rejected
    state :accepted
    state :aml_processing
    state :aml_suspicious
    state :processing
    state :skipped
    state :collected
    state :fee_processing
    event(:cancel) { transitions from: :submitted, to: :canceled }
    event(:reject) { transitions from: :submitted, to: :rejected }
    event :accept do
      transitions from: :submitted, to: :accepted
      after do
        if currency.coin? && Peatio::App.config.deposit_funds_locked
          account.plus_locked_funds(amount)
        else
          account.plus_funds(amount)
        end
        record_submit_operations!
      end
    end
    event :skip do
      transitions from: :processing, to: :skipped
    end

    event :process do
      if Peatio::AML.adapter.present?
        transitions from: %i[aml_processing aml_suspicious accepted], to: :aml_processing do
          after do
            process_collect! if aml_check!
          end
        end
      else
        transitions from: %i[accepted skipped], to: :processing do
          guard { currency.coin? }
        end
      end
    end

    event :fee_process do
      transitions from: %i[accepted processing skipped], to: :fee_processing do
        guard { currency.coin? }
      end
    end

    event :process_collect do
      transitions from: %i[aml_processing aml_suspicious], to: :processing do
        guard { currency.coin? }
      end
    end if Peatio::AML.adapter.present?

    event :aml_suspicious do
      transitions from: :aml_processing, to: :aml_suspicious
    end if Peatio::AML.adapter.present?

    event :dispatch do
      transitions from: %i[processing fee_processing], to: :collected
      after do
        if Peatio::App.config.deposit_funds_locked
          account.unlock_funds(amount)
          record_complete_operations!
        end
      end
    end

    event :refund do
      transitions from: %i[aml_suspicious skipped], to: :refunding do
        guard { currency.coin? }
      end
    end
  end

  def aml_check!
    from_addresses.each do |address|
      result = Peatio::AML.check!(address, currency_id, member.uid)
      if result.risk_detected
        aml_suspicious!
        return nil
      end
      return nil if result.pending
    end
    true
  end

  def blockchain_api
    currency.blockchain_api
  end

  def confirmations
    return 0 if block_number.blank?
    return blockchain.processed_height - block_number if (blockchain.processed_height - block_number) >= 0
    'N/A'
  rescue StandardError => e
    report_exception(e)
    'N/A'
  end

  def spread_to_transactions
    spread.map { |s| Peatio::Transaction.new(s) }
  end

  def spread_between_wallets!
    return false if spread.present?

    spread = WalletService.new(Wallet.deposit_wallet(currency_id)).spread_deposit(self)
    update!(spread: spread.map(&:as_json))
  end

  def spread
    super.map(&:symbolize_keys)
  end

  def account
    member&.get_account(currency)
  end

  def uid
    member&.uid
  end

  def uid=(uid)
    self.member = Member.find_by_uid(uid)
  end

  def as_json_for_event_api
    { tid:                      tid,
      user:                     { uid: member.uid, email: member.email },
      uid:                      member.uid,
      currency:                 currency_id,
      amount:                   amount.to_s('F'),
      state:                    aasm_state,
      created_at:               created_at.iso8601,
      updated_at:               updated_at.iso8601,
      completed_at:             completed_at&.iso8601,
      blockchain_address:       address,
      blockchain_txid:          txid }
  end

  def completed?
    !submitted?
  end

  private

  # Creates dependant operations for deposit.
  def record_submit_operations!
    transaction do
      # Credit main fiat/crypto Asset account.
      Operations::Asset.credit!(
        amount: amount + fee,
        currency: currency,
        reference: self
      )

      # Credit main fiat/crypto Revenue account.
      Operations::Revenue.credit!(
        amount: fee,
        currency: currency,
        reference: self,
        member_id: member_id
      )

      kind = currency.coin? && Peatio::App.config.deposit_funds_locked ? :locked : :main
      # Credit locked fiat/crypto Liability account.
      Operations::Liability.credit!(
        amount: amount,
        currency: currency,
        reference: self,
        member_id: member_id,
        kind: kind
      )
    end
  end

  # Creates dependant operations for complete deposit.
  def record_complete_operations!
    transaction do
      Operations::Liability.transfer!(
        amount:     amount,
        currency:   currency,
        reference:  self,
        from_kind:  :locked,
        to_kind:    :main,
        member_id:  member_id
      )
    end
  end
end

# == Schema Information
# Schema version: 20200827105929
#
# Table name: deposits
#
#  id             :integer          not null, primary key
#  member_id      :integer          not null
#  currency_id    :string(10)       not null
#  amount         :decimal(32, 16)  not null
#  fee            :decimal(32, 16)  not null
#  address        :string(95)
#  from_addresses :string(1000)
#  txid           :string(128)
#  txout          :integer
#  aasm_state     :string(30)       not null
#  block_number   :integer
#  type           :string(30)       not null
#  transfer_type  :integer
#  tid            :string(64)       not null
#  spread         :string(1000)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  completed_at   :datetime
#
# Indexes
#
#  index_deposits_on_aasm_state_and_member_id_and_currency_id  (aasm_state,member_id,currency_id)
#  index_deposits_on_currency_id                               (currency_id)
#  index_deposits_on_currency_id_and_txid_and_txout            (currency_id,txid,txout) UNIQUE
#  index_deposits_on_member_id_and_txid                        (member_id,txid)
#  index_deposits_on_tid                                       (tid)
#  index_deposits_on_type                                      (type)
#
