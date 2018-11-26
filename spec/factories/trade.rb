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

    # Create liability history for orders by passing with_deposit_liability trait.
    trait :with_deposit_liability do
      ask { create(:order_ask, :with_deposit_liability) }
      bid { create(:order_bid, :with_deposit_liability) }
    end

    trait :submitted_orders do
      before(:create) { |trade| Ordering.new([trade.bid, trade.ask]).submit }
    end
  end
end
