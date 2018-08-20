# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :btc_withdraw, class: Withdraws::Coin do
    currency { Currency.find(:btc) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type 'Withdraws::Coin'

    account do
      member.get_account(:btc).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :usd_withdraw, class: Withdraws::Fiat do
    member { create(:member, :level_3) }
    currency { Currency.find(:usd) }
    rid { Faker::Bank.iban }
    sum { 1000.to_d }
    type 'Withdraws::Fiat'

    account do
      member.get_account(:usd).tap do |a|
        a.balance = 50_000
        a.save(validate: false)
      end
    end
  end

  factory :eth_withdraw, class: Withdraws::Coin do
    currency { Currency.find(:eth) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type 'Withdraws::Coin'

    account do
      member.get_account(:eth).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :ltc_withdraw, class: Withdraws::Coin do
    currency { Currency.find(:ltc) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type 'Withdraws::Coin'

    account do
      member.get_account(:ltc).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :dash_withdraw, class: Withdraws::Coin do
    currency { Currency.find(:dash) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type 'Withdraws::Coin'

    account do
      member.get_account(:dash).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :bch_withdraw, class: Withdraws::Coin do
    currency { Currency.find(:bch) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type 'Withdraws::Coin'

    account do
      member.get_account(:bch).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :trst_withdraw, class: Withdraws::Coin do
    currency { Currency.find(:trst) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type 'Withdraws::Coin'

    account do
      member.get_account(:trst).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :xrp_withdraw, class: Withdraws::Coin do
    currency { Currency.find(:xrp) }
    member { create(:member, :level_3) }
    rid 'r4kpJtnx4goLYXoRdi7mbkRpZ9Xpx2RyPN'
    sum { 10.to_d }
    type 'Withdraws::Coin'

    account do
      member.get_account(:xrp).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end
end
