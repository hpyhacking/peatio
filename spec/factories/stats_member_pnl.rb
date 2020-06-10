# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :stats_member_pnl do
    member { create(:member, :level_3) }
    currency_id { Currency.ids.sample }
    pnl_currency_id { Currency.ids.sample }
    total_credit { 0 }
    total_debit_fees { 0 }
    total_credit_fees { 0 }
    total_debit { 0 }
    total_credit_value { 0 }
    total_debit_value { 0 }
    total_balance_value { 0 }
    average_balance_price { 0 }
  end
end
