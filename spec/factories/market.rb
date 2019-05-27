# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :market do
    trait :btcusd do
      id             { 'btcusd' }
      ask_unit       { 'btc' }
      bid_unit       { 'usd' }
      ask_fee        { 0.0015 }
      bid_fee        { 0.0015 }
      ask_precision  { 4 }
      bid_precision  { 4 }
      min_ask_price  { 0.0 }
      min_ask_amount { 0.0 }
      min_bid_amount { 0.0 }
      position       { 1 }
      enabled        { true }
    end

    trait :btceth do
      id             { 'btceth' }
      ask_unit       { 'btc' }
      bid_unit       { 'eth' }
      ask_fee        { 0.0015 }
      bid_fee        { 0.0015 }
      ask_precision  { 4 }
      bid_precision  { 4 }
      min_ask_price  { 0.0 }
      min_ask_amount { 0.0 }
      min_bid_amount { 0.0 }
      position       { 3 }
      enabled        { true }
    end
  end
end
