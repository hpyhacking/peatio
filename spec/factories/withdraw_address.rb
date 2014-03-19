FactoryGirl.define do
  factory :withdraw_address do
    label 'bitcoin address'
    address '1bitcoinaddress'
    category :btc
    is_locked false

    account { create(:member).accounts.first }

    trait :cny do
      label 'cny bank'
      address 'cnybankaddress'
      category :cny
    end

    factory :cny_withdraw_address, traits: [:cny]
    factory :btc_withdraw_address
  end
end

