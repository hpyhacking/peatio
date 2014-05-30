FactoryGirl.define do
  factory :order_bid do
    bid :cny
    ask :btc
    currency :btccny
    state :wait
    source 'Web'
    ord_type 'limit'
    price { '1'.to_d }
    volume { '1'.to_d }
    origin_volume { volume }
    locked { '1'.to_d }
    origin_locked { '1'.to_d }
  end

  factory :order_ask do
    bid :cny
    ask :btc
    currency :btccny
    state :wait
    source 'Web'
    ord_type 'limit'
    price { '1'.to_d }
    volume { '1'.to_d }
    origin_volume { volume }
    locked { '1'.to_d }
    origin_locked { '1'.to_d }
  end
end
