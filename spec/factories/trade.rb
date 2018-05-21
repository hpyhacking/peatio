# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :trade do
    price { '10.0'.to_d }
    volume { '1.0'.to_d }
    funds { price.to_d * volume.to_d }
    market { Market.find(:btcusd) }
    ask { create(:order_ask) }
    bid { create(:order_bid) }
    ask_member { ask.member }
    bid_member { bid.member }
    trend { %w[up down].sample }
  end
end
