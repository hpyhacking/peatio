# encoding: UTF-8
# frozen_string_literal: true

# Legacy withdraw factories are deprecated because they update
# account balance in database without creating liability operation.
#
# Use new withdraw factories instead.
# You can create liability history by passing with_deposit_liability trait.
#
# TODO: Add new factories for all currencies.
# TODO: Use new withdraw factories.
# TODO: Get rid of legacy withdraw factories.
FactoryBot.define do
  factory :legacy_btc_withdraw, aliases: %i[btc_withdraw], class: Withdraws::Coin do
    currency { Currency.find(:btc) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type { 'Withdraws::Coin' }

    account do
      member.get_account(:btc).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :legacy_usd_withdraw, aliases: %i[usd_withdraw], class: Withdraws::Fiat do
    member { create(:member, :level_3) }
    currency { Currency.find(:usd) }
    rid { Faker::Bank.iban }
    sum { 1000.to_d }
    type { 'Withdraws::Fiat' }

    account do
      member.get_account(:usd).tap do |a|
        a.balance = 50_000
        a.save(validate: false)
      end
    end
  end

  factory :legacy_eth_withdraw, aliases: %i[eth_withdraw], class: Withdraws::Coin do
    currency { Currency.find(:eth) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type { 'Withdraws::Coin' }

    account do
      member.get_account(:eth).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :legacy_ltc_withdraw, aliases: %i[ltc_withdraw], class: Withdraws::Coin do
    currency { Currency.find(:ltc) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type { 'Withdraws::Coin' }

    account do
      member.get_account(:ltc).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :legacy_dash_withdraw, aliases: %i[dash_withdraw], class: Withdraws::Coin do
    currency { Currency.find(:dash) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type { 'Withdraws::Coin' }

    account do
      member.get_account(:dash).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :legacy_bch_withdraw, aliases: %i[bch_withdraw], class: Withdraws::Coin do
    currency { Currency.find(:bch) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type { 'Withdraws::Coin' }

    account do
      member.get_account(:bch).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :legacy_trst_withdraw, aliases: %i[trst_withdraw], class: Withdraws::Coin do
    currency { Currency.find(:trst) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type { 'Withdraws::Coin' }

    account do
      member.get_account(:trst).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :legacy_xrp_withdraw, aliases: %i[xrp_withdraw], class: Withdraws::Coin do
    currency { Currency.find(:xrp) }
    member { create(:member, :level_3) }
    rid { 'r4kpJtnx4goLYXoRdi7mbkRpZ9Xpx2RyPN' }
    sum { 10.to_d }
    type { 'Withdraws::Coin' }

    account do
      member.get_account(:xrp).tap do |a|
        a.balance = 50
        a.save(validate: false)
      end
    end
  end

  factory :new_btc_withdraw, class: Withdraws::Coin do

    # We need to have valid Liability-based balance to spend funds.
    trait :with_deposit_liability do
      before(:create) do |withdraw|
        create(:deposit_btc, member: withdraw.member, amount: withdraw.sum)
          .accept!
      end
    end

    currency { Currency.find(:btc) }
    member { create(:member, :level_3) }
    rid { Faker::Bitcoin.address }
    sum { 10.to_d }
    type { 'Withdraws::Coin' }
  end

  factory :new_usd_withdraw, class: Withdraws::Fiat do

    # We need to have valid Liability-based balance to spend funds.
    trait :with_deposit_liability do
      before(:create) do |withdraw|
        create(:deposit_usd, member: withdraw.member, amount: withdraw.sum)
          .accept!
      end
    end

    member { create(:member, :level_3) }
    currency { Currency.find(:usd) }
    rid { Faker::Bank.iban }
    sum { 1000.to_d }
    type { 'Withdraws::Fiat' }
  end
end
