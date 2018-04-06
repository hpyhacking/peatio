FactoryBot.define do
  factory :btc_withdraw, class: Withdraws::Coin do
    currency { Currency.find_by!(code: :btc) }
    member { create(:member, :verified_identity) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type 'Withdraws::Coin'

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

  factory :usd_withdraw, class: Withdraws::Fiat do
    member { create(:member, :verified_identity) }
    currency { Currency.find_by!(code: :usd) }
    rid { Faker::Bank.iban }
    sum { 1000.to_d }
    type 'Withdraws::Fiat'

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
