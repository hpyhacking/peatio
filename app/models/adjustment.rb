# encoding: UTF-8
# frozen_string_literal: true

class Adjustment < ApplicationRecord
  # == Constants ============================================================

  include AASM
  include AASM::Locking
  CATEGORIES = %w[asset_registration investment minting_token
                  balance_anomaly misc refund compensation
                  incentive bank_fees bank_interest minor]

  # == Attributes ===========================================================

  enum category: CATEGORIES

  enum state: { pending: 1, accepted: 2, rejected: 3 }

  # == Relationships ========================================================

  belongs_to :currency
  belongs_to :creator, class_name: :Member, required: true
  belongs_to :validator, class_name: :Member

  # Need to define reference type for avoid fetching operations that not related to Adjustments.
  # TODO: Find a better way to associate Adjustments with operations.
  has_one :asset, -> { where(reference_type: 'Adjustment') }, class_name: 'Operations::Asset', foreign_key: :reference_id
  has_one :liability, -> { where(reference_type: 'Adjustment') }, class_name: 'Operations::Liability', foreign_key: :reference_id
  has_one :revenue, -> { where(reference_type: 'Adjustment') }, class_name: 'Operations::Revenue', foreign_key: :reference_id
  has_one :expense, -> { where(reference_type: 'Adjustment') }, class_name: 'Operations::Expense', foreign_key: :reference_id

  # == Validations ==========================================================

  validates :validator, presence: { unless: :pending? }
  validates :category, inclusion: { in: CATEGORIES }
  validates :currency_id, inclusion: { in: ->(_) { Currency.codes } }

  validate on: :create do
    errors.add(:prebuild_operations, 'are invalid') unless prebuild_operations.map(&:valid?).all?(true)
  end

  # == Extensions ===========================================================

  aasm column: :state, enum: true, whiny_transitions: false do
    state :pending, initial: true
    state :accepted
    state :rejected

    event :accept do
      transitions from: :pending, to: :accepted, after: :assign_validator do
        guard do
          prebuild_operations.map(&:valid?).all?(true)
        end
        after do
          prebuild_operations.map(&:save!)
          Operations.update_legacy_balance(liability)
        end
      end
    end

    event :reject do
      transitions from: :pending, to: :rejected, after: :assign_validator
    end
  end

  # Custom ransackers.

  ransacker :state, formatter: proc { |v| states[v] } do |parent|
    parent.table[:state]
  end

  ransacker :category, formatter: proc { |v| categories[v] } do |parent|
    parent.table[:category]
  end

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  # == Instance Methods =====================================================

  def assign_validator(validator:)
    update!(validator: validator)
  end

  def fetch_operations
    if pending? || rejected?
      prebuild_operations
    elsif accepted?
      load_operations
    end
  end

  def load_operations
    operations = %i[asset liability revenue expense].map do |op_type|
      "Operations::#{op_type.capitalize}".constantize.find_by(reference: self)
    end
    operations.compact
  end

  %i[asset liability revenue expense].each do |op_type|
    define_method("fetch_#{op_type}") do
      fetch_operations.find { |op| op.is_a?("Operations::#{op_type.capitalize}".constantize) }
    end
  end

  def prebuild_operations
    account_number_hash = Operations.split_account_number(account_number: receiving_account_number)
    currency_id = account_number_hash[:currency_id]
    code = account_number_hash[:code]
    member = Member.find_by(uid: account_number_hash[:member_uid]) if account_number_hash.key?(:member_uid)

    amount > 0 ? credit = amount : debit = -amount

    klass = Operations.klass_for(code: code)

    params = {
      currency_id: currency_id,
      code: asset_account_code,
      debit: debit.to_d,
      credit: credit.to_d,
      reference: self
    }

    asset = Operations::Asset.new(params)
    # For expense we need swap debit and credit values due to:
    # asset - liabilities = revenue - expense
    params.merge!(credit: debit.to_d, debit: credit.to_d) if klass == Operations::Expense
    params.merge!(member_id: member.id) if member.present? && klass.column_names.include?('member_id')
    receiving_operation = klass.new(params.merge(code: code))
    [asset, receiving_operation]
  end
end

# == Schema Information
# Schema version: 20190830082950
#
# Table name: adjustments
#
#  id                       :bigint           not null, primary key
#  reason                   :string(255)      not null
#  description              :text(65535)      not null
#  creator_id               :bigint           not null
#  validator_id             :bigint
#  amount                   :decimal(32, 16)  not null
#  asset_account_code       :integer          unsigned, not null
#  receiving_account_number :string(64)       not null
#  currency_id              :string(255)      not null
#  category                 :integer          not null
#  state                    :integer          not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_adjustments_on_currency_id            (currency_id)
#  index_adjustments_on_currency_id_and_state  (currency_id,state)
#
