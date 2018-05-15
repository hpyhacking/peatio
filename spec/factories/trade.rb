# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :trade do
    price '10.0'
    volume '1.0'
    funds { price.to_d * volume.to_d }
    market { Market.find(:btcusd) }
    ask { create(:order_ask) }
    bid { create(:order_bid) }
    ask_member { ask.member }
    bid_member { bid.member }
  end
end
