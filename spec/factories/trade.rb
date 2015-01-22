FactoryGirl.define do
  factory :trade do
    price "10.0"
    volume 1
    funds {price.to_d * volume.to_d}
    currency :btccny
    association :ask, factory: :order_ask
    association :bid, factory: :order_bid
    ask_member { ask.member }
    bid_member { bid.member }
  end
end
