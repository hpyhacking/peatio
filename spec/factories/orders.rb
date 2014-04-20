FactoryGirl.define do
  factory :order_bid do
    bid :cny
    ask :btc
    currency :btccny
    state :wait
    source 'Web'
    volume { '1'.to_d }
    price { '1'.to_d }
    origin_volume { volume }
  end

  factory :order_ask do
    bid :cny
    ask :btc
    currency :btccny
    state :wait
    source 'Web'
    volume { '1'.to_d }
    price { '1'.to_d }
    origin_volume { volume }
  end
end
