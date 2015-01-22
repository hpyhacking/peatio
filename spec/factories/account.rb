FactoryGirl.define do
  factory :account do
    locked { "0.0".to_d }
    balance { "100.0".to_d }
    currency :cny

    factory :account_btc do
      currency :btc
    end
  end
end

