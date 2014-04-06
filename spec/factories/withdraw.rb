FactoryGirl.define do
  factory :satoshi_withdraw, class: Withdraws::Satoshi do
    sum { 10.to_d }
    currency :btc
    fund_uid 'sample_to_long_long_long_address'
    fund_extra 'sample'
    member { create :member }
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
  end

  factory :bank_withdraw, class: Withdraws::Bank do
    member { create :member }
    currency :cny
    fund_uid 'sample_to_long_long_long_address'
    fund_extra { 'cmb' }
    sum { 1000.to_d }
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
