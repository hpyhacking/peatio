# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :adjustment do
    reason { Faker::Coffee.blend_name }
    description { Faker::Coffee.notes }
    category { 'asset_registration' }
    amount { Faker::Number.positive }
    currency_id { Currency.ids.sample }
    creator { create(:member) }
    asset_account_code { 102 }
    receiving_account_number { "BTC-#{[402, 302].sample}" }
  end
end
