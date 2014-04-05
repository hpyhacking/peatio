FactoryGirl.define do
  factory :trade do
    price "10.0"
    volume 1
    currency :btccny
    association :ask, factory: :order_ask
    association :bid, factory: :order_bid
  end
end
