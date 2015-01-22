# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment_address do
    address "MyString"
    account { create(:member).get_account(:cny) }

    trait :btc_address do
      address { Faker::Bitcoin.address }
      account { create(:member).get_account(:btc) }
      currency Currency.find_by_code('btc').id
    end

    factory :btc_payment_address, traits: [:btc_address]
  end
end
