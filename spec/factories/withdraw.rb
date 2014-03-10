FactoryGirl.define do
  factory :withdraw do
    sum { 10.to_d }
    state :wait
    currency :btc
    address 'sample_to_long_long_long_address'
    address_label 'sample'
    address_type :satoshi
    member { create :member }

    account do
      member.accounts.first.tap do |a|
        a.balance = 50000
        a.save(validate: false)
      end
    end

    trait :bank do
      currency :cny
      address_type :bank
      address_label { member.name }
      sum { 1000.to_d }
    end
  end
end

