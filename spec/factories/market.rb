FactoryBot.define do
  factory :market do
    trait :btcusd do
      id            'btcusd'
      ask_unit      'btc'
      bid_unit      'usd'
      ask_fee       0.0015
      bid_fee       0.0015
      ask_precision 4
      bid_precision 2
      position      1
      visible       true
    end

    trait :dashbtc do
      id            'dashbtc'
      ask_unit      'dash'
      bid_unit      'btc'
      ask_fee       0.0015
      bid_fee       0.0015
      ask_precision 4
      bid_precision 4
      position      2
      visible       false
    end
  end
end
