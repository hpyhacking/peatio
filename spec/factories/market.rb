# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :market do
    trait :btcusd do
      id                { 'btcusd' }
      base_currency     { 'btc' }
      quote_currency    { 'usd' }
      maker_fee         { 0.0015 }
      taker_fee         { 0.0015 }
      amount_precision  { 8 }
      price_precision   { 2 }
      min_price         { 0.01 }
      min_amount        { 0.00000001 }
      position          { 1 }
      state             { :enabled }
    end

    trait :btceth do
      id                { 'btceth' }
      base_currency     { 'btc' }
      quote_currency    { 'eth' }
      maker_fee         { 0.0015 }
      taker_fee         { 0.0015 }
      amount_precision  { 4 }
      price_precision   { 6 }
      min_price         { 0.000001 }
      min_amount        { 0.0001 }
      position          { 3 }
      state             { :enabled }
    end
  end
end
