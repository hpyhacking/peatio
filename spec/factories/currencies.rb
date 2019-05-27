# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :currency do
    trait :usd do
      code                 { 'usd' }
      symbol               { '$' }
      type                 { 'fiat' }
      precision            { 2 }
      withdraw_limit_24h   { 100 }
      withdraw_limit_72h   { 1000 }
      withdraw_fee         { 0.1 }
      position             { 0 }
      options              { {} }
    end

    trait :eur do
      code                 { 'eur' }
      symbol               { '€' }
      type                 { 'fiat' }
      precision            { 8 }
      withdraw_limit_24h   { 100 }
      withdraw_limit_72h   { 1000 }
      withdraw_fee         { 0.1 }
      position             { 1 }
      enabled              { false }
      options              { {} }
    end

    trait :btc do
      blockchain_key       { 'btc-testnet' }
      code                 { 'btc' }
      symbol               { '฿' }
      type                 { 'coin' }
      base_factor          { 100_000_000 }
      withdraw_limit_24h   { 0.1 }
      withdraw_limit_72h   { 1 }
      withdraw_fee         { 0.01 }
      position             { 2 }
      options              { {} }
    end

    trait :eth do
      blockchain_key       { 'eth-rinkeby' }
      code                 { 'eth' }
      symbol               { 'Ξ' }
      type                 { 'coin' }
      base_factor          { 1_000_000_000_000_000_000 }
      withdraw_limit_24h   { 0.1 }
      withdraw_limit_72h   { 1 }
      withdraw_fee         { 0.025 }
      position             { 4 }
      options do
        { gas_limit: 21_000,
          gas_price: 1_000_000_000 }
      end
    end

    trait :trst do
      blockchain_key       { 'eth-rinkeby' }
      code                 { 'trst' }
      symbol               { 'Ξ' }
      type                 { 'coin' }
      base_factor          { 1_000_000 }
      withdraw_limit_24h   { 100 }
      withdraw_limit_72h   { 1000 }
      withdraw_fee         { 0.025 }
      position             { 6 }
      options do
        { gas_limit: 90_000,
          gas_price: 1_000_000_000,
          erc20_contract_address: '0x87099adD3bCC0821B5b151307c147215F839a110' }
      end
    end

    trait :ring do
      blockchain_key       { 'eth-kovan' }
      code                 { 'ring' }
      symbol               { 'Ξ' }
      type                 { 'coin' }
      base_factor          { 1_000_000 }
      withdraw_limit_24h   { 100 }
      withdraw_limit_72h   { 1000 }
      withdraw_fee         { 0.025 }
      position             { 7 }
      options \
        { { erc20_contract_address: '0xf8720eb6ad4a530cccb696043a0d10831e2ff60e' } }
    end

    trait :fake do
      blockchain_key      { 'fake-testnet' }
      code                { 'fake' }
      symbol              { 'F' }
      type                { 'coin' }
      base_factor         { 1_000_000 }
      withdraw_limit_24h  { 100 }
      withdraw_limit_72h  { 1000 }
      withdraw_fee        { 0.02 }
      position            { 10 }
      options             { {} }
    end
  end
end
