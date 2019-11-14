# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :deposit do
    member { create(:member, :level_3) }
    amount { Kernel.rand(100..10_000).to_d }

    factory :deposit_btc, class: Deposits::Coin do
      currency { Currency.find(:btc) }
      address { Faker::Blockchain::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
      block_number { rand(1..1349999) }
    end

    factory :deposit_usd, class: Deposits::Fiat do
      currency { Currency.find(:usd) }
    end

    trait :deposit_btc do
      type { Deposits::Coin }
      currency { Currency.find(:btc) }
      address { Faker::Blockchain::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end

    trait :deposit_eth do
      type { Deposits::Coin }
      currency { Currency.find(:eth) }
      member { create(:member, :level_3, :barong) }
      address { Faker::Blockchain::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end

    trait :deposit_trst do
      type { Deposits::Coin }
      currency { Currency.find(:trst) }
      member { create(:member, :level_3, :barong) }
      address { Faker::Blockchain::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end

    trait :deposit_ring do
      type { Deposits::Coin }
      currency { Currency.find(:ring) }
      member { create(:member, :level_3, :barong) }
      address { Faker::Blockchain::Bitcoin.address }
      txid { Faker::Lorem.characters(64) }
      txout { 0 }
    end
  end
end
