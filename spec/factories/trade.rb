# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :trade do
    trait :btcusd do
      price { '10.0'.to_d }
      volume { '1.0'.to_d }
      funds { price.to_d * volume.to_d }
      market { Market.find(:btcusd) }
      ask { create(:order_ask, :btcusd) }
      bid { create(:order_bid, :btcusd) }
      ask_member { ask.member }
      bid_member { bid.member }
      trend { %w[up down].sample }
    end

    trait :btceth do
      price { '10.0'.to_d }
      volume { '1.0'.to_d }
      funds { price.to_d * volume.to_d }
      market { Market.find(:btceth) }
      ask { create(:order_ask, :btceth) }
      bid { create(:order_bid, :btceth) }
      ask_member { ask.member }
      bid_member { bid.member }
      trend { %w[up down].sample }
    end

    # Create liability history for orders by passing with_deposit_liability trait.
    trait :with_deposit_liability do
      ask { create(:order_ask, :with_deposit_liability) }
      bid { create(:order_bid, :with_deposit_liability) }
    end
  end
end
