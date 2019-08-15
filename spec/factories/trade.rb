# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :trade do
    trait :btcusd do
      price { '10.0'.to_d }
      amount { '1.0'.to_d }
      total { price.to_d * amount.to_d }
      market { Market.find(:btcusd) }
      maker_order { create(:order_ask, :btcusd) }
      taker_order { create(:order_bid, :btcusd) }
      maker { maker_order.member }
      taker { taker_order.member }
    end

    trait :btceth do
      price { '10.0'.to_d }
      amount { '1.0'.to_d }
      total { price.to_d * amount.to_d }
      market { Market.find(:btceth) }
      maker_order { create(:order_ask, :btceth) }
      taker_order { create(:order_bid, :btceth) }
      maker { maker_order.member }
      taker { taker_order.member }
    end

    # Create liability history for orders by passing with_deposit_liability trait.
    trait :with_deposit_liability do
      maker_order { create(:order_ask, :with_deposit_liability) }
      taker_order { create(:order_bid, :with_deposit_liability) }
    end
  end
end
