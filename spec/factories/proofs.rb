# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :proof do
    root 'root: {}'
    ready true
    currency_id { Currency.find_by_code(:btc).id }
  end
end
