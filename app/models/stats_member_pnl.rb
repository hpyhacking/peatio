# encoding: UTF-8
# frozen_string_literal: true

class StatsMemberPnl < ApplicationRecord
  self.table_name = 'stats_member_pnl'

  # == Constants ============================================================

  # == Extensions ===========================================================

  # == Attributes ===========================================================

  # == Relationships ========================================================

  belongs_to :currency, required: true, foreign_key: :currency_id
  belongs_to :currency, required: true, foreign_key: :pnl_currency_id
  belongs_to :member, required: true

  # == Validations ==========================================================

  validates :total_credit, :total_debit, :total_credit_fees, :total_debit_fees,
            :total_credit_value, :total_debit_value,
            numericality: { greater_than_or_equal_to: 0 }
  # == Scopes ===============================================================

  default_scope { order(id: :asc) }

  # == Callbacks ============================================================

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
end

# == Schema Information
# Schema version: 20210609094033
#
# Table name: stats_member_pnl
#
#  id                    :bigint           not null, primary key
#  member_id             :bigint           not null
#  pnl_currency_id       :string(10)       not null
#  currency_id           :string(10)       not null
#  total_credit          :decimal(48, 16)  default(0.0)
#  total_credit_fees     :decimal(48, 16)  default(0.0)
#  total_debit_fees      :decimal(48, 16)  default(0.0)
#  total_debit           :decimal(48, 16)  default(0.0)
#  total_credit_value    :decimal(48, 16)  default(0.0)
#  total_debit_value     :decimal(48, 16)  default(0.0)
#  total_balance_value   :decimal(48, 16)  default(0.0)
#  average_balance_price :decimal(48, 16)  default(0.0)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_currency_ids_and_member_id  (pnl_currency_id,currency_id,member_id) UNIQUE
#
