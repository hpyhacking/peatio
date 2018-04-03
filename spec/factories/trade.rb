FactoryBot.define do
  factory :trade do
    price '10.0'
    volume 1
    funds { price.to_d * volume.to_d }
    market { Market.find(:btcusd) }
    association :ask, factory: :order_ask
    association :bid, factory: :order_bid
    ask_member { ask.member }
    bid_member { bid.member }
  end
end
