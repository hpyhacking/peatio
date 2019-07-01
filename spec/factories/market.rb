# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :market do
    trait :btcusd do
      id                { 'btcusd' }
      base_unit         { 'btc' }
      quote_unit        { 'usd' }
      ask_fee           { 0.0015 }
      bid_fee           { 0.0015 }
      amount_precision  { 4 }
      price_precision   { 4 }
      min_price         { 0.0 }
      min_amount        { 0.0 }
      position          { 1 }
      state             { :enabled }
    end

    trait :btceth do
      id                { 'btceth' }
      base_unit         { 'btc' }
      quote_unit        { 'eth' }
      ask_fee           { 0.0015 }
      bid_fee           { 0.0015 }
      amount_precision  { 4 }
      price_precision   { 4 }
      min_price         { 0.0 }
      min_amount        { 0.0 }
      position          { 3 }
      state             { :enabled }
    end
  end
end
