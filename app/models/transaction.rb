class Transaction < ApplicationRecord
  # == Constants ============================================================

  STATUSES = %w[pending succeed].freeze

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  serialize :data, JSON unless Rails.configuration.database_support_json

  # == Relationships ========================================================

  belongs_to :reference, polymorphic: true
  belongs_to :currency, foreign_key: :currency_id

  # == Validations ==========================================================

  validates :currency, :amount, :from_address, :to_address, :status, presence: true

  validates :status, inclusion: { in: STATUSES }

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  after_initialize :initialize_defaults, if: :new_record?

  # TODO: record expenses for succeed transactions

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def initialize_defaults
    self.status = :pending if status.blank?
  end
end

# == Schema Information
# Schema version: 20201207134745
#
# Table name: transactions
#
#  id             :bigint           not null, primary key
#  currency_id    :string(255)      not null
#  reference_type :string(255)
#  reference_id   :bigint
#  txid           :string(255)
#  from_address   :string(255)
#  to_address     :string(255)
#  amount         :decimal(32, 16)  default(0.0), not null
#  block_number   :integer
#  txout          :integer
#  status         :string(255)
#  options        :json
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_transactions_on_currency_id                      (currency_id)
#  index_transactions_on_currency_id_and_txid             (currency_id,txid) UNIQUE
#  index_transactions_on_reference_type_and_reference_id  (reference_type,reference_id)
#  index_transactions_on_txid                             (txid)
#
