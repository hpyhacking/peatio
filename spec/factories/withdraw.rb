FactoryBot.define do
  factory :satoshi_withdraw, class: Withdraws::Satoshi do
    currency { Currency.find_by!(code: :btc) }
    member { create(:member, :verified_identity) }
    fund_source_id { create(:btc_fund_source, member: member, currency: currency).id }
    sum { 10.to_d }
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
    member { create(:member, :verified_identity) }
    currency { Currency.find_by!(code: :usd) }
    fund_source_id { create(:usd_fund_source, member: member, currency: currency).id }
    sum { 1000.to_d }
    type 'Withdraws::Bank'

    account do
      member.get_account(:usd).tap do |a|
        a.balance = 50_000
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
