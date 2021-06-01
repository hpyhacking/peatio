# encoding: UTF-8
# frozen_string_literal: true

class Transfer < ApplicationRecord

  # == Constants ============================================================

  extend Enumerize

  CATEGORIES = %w[wire refund purchases commission airdrop].freeze
  CATEGORIES_MAPPING = { wire: 1, refund: 2, purchases: 3, commission: 4, airdrop: 5 }.freeze

  # == Attributes ===========================================================

  enumerize :category, in: CATEGORIES_MAPPING, scope: true

  # == Extensions ===========================================================

  # == Relationships ========================================================

  # Define has_many relation with Operations::{Asset,Expense,Liability,Revenue}.
  ::Operations::Account::TYPES.map(&:pluralize).each do |op_t|
    has_many op_t.to_sym,
             class_name: "::Operations::#{op_t.to_s.singularize.camelize}",
             as: :reference
  end

  # == Validations ==========================================================

  validates :key, uniqueness: true, presence: true
  validates :category, presence: true
  validate do
    errors.add(:base, 'invalidates accounting equation') unless Operations.validate_accounting_equation(operations)
  end

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  before_create { self.key = self.key.strip.downcase }
  before_commit on: :create do
    update_legacy_balances
  end

  # == Class Methods ========================================================

  # == Instance Methods =====================================================

  def update_legacy_balances
    liabilities.where.not(member_id: nil).find_each { |l| Operations.update_legacy_balance(l) }
  end

  def operations
    assets + liabilities + revenues + expenses
  end
end

# == Schema Information
# Schema version: 20210609094033
#
# Table name: transfers
#
#  id          :bigint           not null, primary key
#  key         :string(30)       not null
#  category    :integer          not null
#  description :string(255)      default("")
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_transfers_on_key  (key) UNIQUE
#
