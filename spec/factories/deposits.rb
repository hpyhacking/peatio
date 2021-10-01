# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :deposit do
    member { create(:member, :level_3) }
    amount { Kernel.rand(100..10_000).to_d }

    factory :deposit_btc, class: Deposits::Coin do
      currency { Currency.find(:btc) }
      blockchain_key { 'btc-testnet' }
      address { create(:payment_address, :btc_address).address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
      block_number { rand(1..1349999) }
    end

    factory :deposit_usd, class: Deposits::Fiat do
      currency { Currency.find(:usd) }
      blockchain_key { 'fiat' }
    end

    trait :deposit_btc do
      type { Deposits::Coin }
      blockchain_key { 'btc-testnet' }
      currency { Currency.find(:btc) }
      address { create(:payment_address, :btc_address).address  }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end

    trait :deposit_eth do
      type { Deposits::Coin }
      currency { Currency.find(:eth) }
      blockchain_key { 'eth-rinkeby' }
      member { create(:member, :level_3, :barong) }
      address { create(:payment_address, :eth_address).address  }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end

    trait :deposit_trst do
      type { Deposits::Coin }
      currency { Currency.find(:trst) }
      blockchain_key { 'eth-rinkeby' }
      member { create(:member, :level_3, :barong) }
      address { create(:payment_address, :trst_address).address  }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end

    trait :deposit_ring do
      type { Deposits::Coin }
      currency { Currency.find(:ring) }
      blockchain_key { 'eth-rinkeby' }
      member { create(:member, :level_3, :barong) }
      address { create(:payment_address, :trst_address).address  }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end
  end
end
