FactoryGirl.define do
  factory :satoshi_withdraw, class: Withdraws::Satoshi do
    sum { 10.to_d }
    currency :btc
    member { create :member }
    fund_source_id { create(:btc_fund_source).id }
    type 'Withdraws::Satoshi'

    account do
      member.get_account(:btc).tap do |a|
        a.balance = 50
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

    after(:build) do |x|
      x.stubs(:validate_address).returns(true)
    end
  end

  factory :bank_withdraw, class: Withdraws::Bank do
    member { create :member }
    currency :cny
    sum { 1000.to_d }
    fund_source_id { create(:cny_fund_source).id }
    type 'Withdraws::Bank'

    account do
      member.get_account(:cny).tap do |a|
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
  end
end
