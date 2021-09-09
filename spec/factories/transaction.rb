# frozen_string_literal: true

FactoryBot.define do
  factory :transaction do
    currency { Currency.all.sample }
    fee_currency { Currency.all.sample }
    txid { Faker::Lorem.characters(64) }
    from_address { Faker::Blockchain::Bitcoin.address }
    to_address { Faker::Blockchain::Bitcoin.address }
    amount { Kernel.rand(100..10_000).to_d }
    fee { Kernel.rand(1..10).to_d }
  end
end
