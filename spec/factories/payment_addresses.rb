# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :payment_address do
    address { Faker::Blockchain::Bitcoin.address }
    member { create(:member, :level_3) }
    wallet { Wallet.joins(:currencies).find_by(currencies: { id: 'usd' }) }

    trait :btc_address do
      member { create(:member, :level_3) }
      wallet { Wallet.joins(:currencies).find_by(currencies: { id: 'btc' }) }
    end

    trait :eth_address do
      member { create(:member, :level_3) }
      wallet { Wallet.joins(:currencies).find_by(currencies: { id: 'eth' }) }
    end

    trait :trst_address do
      member { create(:member, :level_3) }
      wallet { Wallet.joins(:currencies).find_by(currencies: { id: 'trst' }) }
    end

    trait :ring_address do
      member { create(:member, :level_3) }
      wallet { Wallet.joins(:currencies).find_by(currencies: { id: 'ring' }) }
    end

    trait :ltc_address do
      member { create(:member, :level_3) }
      wallet { Wallet.joins(:currencies).find_by(currencies: { id: 'ltc' }) }
    end

    factory :btc_payment_address,  traits: [:btc_address]
    factory :eth_payment_address,  traits: [:eth_address]
    factory :trst_payment_address, traits: [:trst_address]
    factory :ring_payment_address, traits: [:ring_address]
  end
end
