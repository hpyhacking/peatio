# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :currency do
    trait :usd do
      code                 'usd'
      symbol               '$'
      type                 'fiat'
      precision            2
      quick_withdraw_limit 10
      withdraw_fee         0.1
    end

    trait :eur do
      code                 'eur'
      symbol               '€'
      type                 'fiat'
      precision            8
      quick_withdraw_limit 1000
      withdraw_fee         0.1
      enabled              false
    end

    trait :btc do
      blockchain_key       'btc-testnet'
      code                 'btc'
      symbol               '฿'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 0.1
      withdraw_fee         0.01
    end

    trait :dash do
      blockchain_key       'dash-testnet'
      code                 'dash'
      symbol               'Đ'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 1000
      withdraw_fee         0.02
    end

    trait :eth do
      blockchain_key       'eth-rinkeby'
      code                 'eth'
      symbol               'Ξ'
      type                 'coin'
      base_factor          1_000_000_000_000_000_000
      quick_withdraw_limit 1
      withdraw_fee         0.025
    end

    trait :xrp do
      code                 'xrp'
      blockchain_key       'xrp-testnet'
      symbol               'ꭆ'
      type                 'coin'
      base_factor          1_000_000
      quick_withdraw_limit 1000
      withdraw_fee         0.015
    end

    trait :trst do
      blockchain_key       'eth-rinkeby'
      code                 'trst'
      symbol               'Ξ'
      type                 'coin'
      base_factor          1_000_000
      quick_withdraw_limit 1000
      withdraw_fee         0.025
      options \
        erc20_contract_address:           '0x87099adD3bCC0821B5b151307c147215F839a110'
    end

    trait :bch do
      blockchain_key       'bch-testnet'
      code                 'bch'
      symbol               '฿'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 1
      withdraw_fee         0
    end

    trait :ltc do
      blockchain_key       'ltc-testnet'
      code                 'ltc'
      symbol               'Ł'
      type                 'coin'
      base_factor          100_000_000
      quick_withdraw_limit 1000
      withdraw_fee         0.02
    end
  end
end
