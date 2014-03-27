FactoryGirl.define do
  factory :withdraw do
    sum { 10.to_d }
    currency :btc
    fund_uid 'sample_to_long_long_long_address'
    fund_extra 'sample'
    channel_id 200
    member { create :member }

    account do
      member.accounts.first.tap do |a|
        a.balance = 50000
        a.save(validate: false)

        a.versions.create \
          balance: a.balance,
          amount: a.balance,
          locked: 0,
          fee: 0,
          currency: a.currency,
          fun: Account::FUNS[:plus_funds]
      end
    end

    trait :bank do
      currency :cny
      channel_id 400
      fund_extra { member.name }
      sum { 1000.to_d }
    end

    factory :bank_withdraw, traits: [:bank]
  end
end

