# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :payment_address do
    address { Faker::Blockchain::Bitcoin.address }
    currency { Currency.find(:usd) }
    account { create(:member, :level_3).get_account(:usd) }

    trait :btc_address do
      currency { Currency.find(:btc) }
      account { create(:member, :level_3).get_account(:btc) }
    end

    trait :eth_address do
      currency { Currency.find(:eth) }
      account { create(:member, :level_3).get_account(:eth) }
    end

    trait :trst_address do
      currency { Currency.find(:trst) }
      account { create(:member, :level_3).get_account(:trst) }
    end

    trait :ring_address do
      currency { Currency.find(:ring) }
      account { create(:member, :level_3).get_account(:ring) }
    end

    trait :ltc_address do
      currency { Currency.find(:ltc) }
      account { create(:member, :level_3).get_account(:ltc) }
    end

    factory :btc_payment_address,  traits: [:btc_address]
    factory :eth_payment_address,  traits: [:eth_address]
    factory :trst_payment_address, traits: [:trst_address]
    factory :ring_payment_address, traits: [:ring_address]
  end
end
