FactoryBot.define do
  factory :fund_source do
    extra 'bitcoin'
    uid { Faker::Bitcoin.address }
    is_locked false
    currency 'btc'

    member { create(:member) }

    trait :cny do
      extra 'bc'
      uid '123412341234'
      currency 'cny'
    end

    factory :cny_fund_source, traits: [:cny]
    factory :btc_fund_source
  end
end
