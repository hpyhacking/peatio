FactoryBot.define do
  factory :fund_source do
    extra 'bitcoin'
    uid { Faker::Bitcoin.address }
    is_locked false
    currency { Currency.find_by!(code: :btc) }

    member { create(:member, :verified_identity) }

    trait :usd do
      extra 'bc'
      uid '123412341234'
      currency { Currency.find_by!(code: :usd) }
    end

    factory :usd_fund_source, traits: [:usd]
    factory :btc_fund_source
  end
end
