FactoryGirl.define do
  factory :fund_source do
    extra 'bitcoin'
    uid { Faker::Bitcoin.address }
    is_locked false
    currency 'btc'

    member { create(:member) }

    trait :inr do
      extra 'bc'
      uid '123412341234'
      currency 'inr'
    end

    factory :inr_fund_source, traits: [:inr]
    factory :btc_fund_source
  end
end

