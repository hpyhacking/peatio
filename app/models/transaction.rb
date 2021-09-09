# frozen_string_literal: true

class Transaction < ApplicationRecord
  # == Constants ============================================================

  STATUSES = %w[pending succeed rejected failed].freeze
  KINDS = %w[tx tx_prebuild].freeze

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  serialize :options, JSON unless Rails.configuration.database_support_json

  include AASM
  include AASM::Locking

  aasm whiny_transitions: false, column: :status do
    state :pending, initial: true
    state :skipped
    state :failed
    state :rejected
    state :succeed

    event :confirm do
      transitions from: :pending, to: :succeed
      after do
        record_expenses!
      end
    end

    event :fail do
      transitions from: :pending, to: :failed
      after do
        record_expenses!
      end
    end

    event :reject do
      transitions from: :pending, to: :rejected
    end
  end

  # == Relationships ========================================================

  belongs_to :reference, polymorphic: true
  belongs_to :currency, foreign_key: :currency_id
  belongs_to :fee_currency, foreign_key: :fee_currency_id, class_name: 'Currency'
  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  # == Validations ==========================================================

  validates :currency, :amount, :from_address, :to_address, :status, presence: true

  validates :status, inclusion: { in: STATUSES }
  validates :kind, inclusion: { in: KINDS }

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  after_initialize :initialize_defaults, if: :new_record?

  # TODO: record expenses for succeed transactions

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize_defaults
    self.fee_currency_id ||= currency_id
    self.options = {} if options.blank?
  end

  def record_expenses!
    return unless fee?

    Operations::Expense.create!({
                                  code: 402,
                                  currency_id: fee_currency_id,
                                  reference_id: reference_id,
                                  reference_type: reference_type,
                                  debit: 0.0,
                                  credit: fee
                                })
  end
end

# == Schema Information
# Schema version: 20210909120210
#
# Table name: transactions
#
#  id              :bigint           not null, primary key
#  currency_id     :string(255)      not null
#  fee_currency_id :string(255)      not null
#  kind            :string(255)
#  blockchain_key  :string(255)
#  reference_type  :string(255)
#  reference_id    :bigint
#  txid            :string(255)
#  from_address    :string(255)
#  to_address      :string(255)
#  amount          :decimal(32, 16)  default(0.0), not null
#  fee             :decimal(32, 16)
#  block_number    :integer
#  txout           :integer
#  status          :string(255)
#  options         :json
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_transactions_on_currency_id                      (currency_id)
#  index_transactions_on_currency_id_and_txid             (currency_id,txid) UNIQUE
#  index_transactions_on_reference_type_and_reference_id  (reference_type,reference_id)
#  index_transactions_on_txid                             (txid)
#
