# encoding: UTF-8
# frozen_string_literal: true

# Legacy withdraw factories are deprecated because they update
# account balance in database without creating liability operation.
#
# Use new withdraw factories instead.
# You can create liability history by passing with_deposit_liability trait.
#
# TODO: Add new factories for all currencies.
FactoryBot.define do
  factory :btc_withdraw, class: Withdraws::Coin do

    # We need to have valid Liability-based balance to spend funds.
    trait :with_deposit_liability do
      before(:create) do |withdraw|
        deposit = create(:deposit_btc, member: withdraw.member, amount: withdraw.sum)
        deposit.accept!
        deposit.process!
        deposit.dispatch!
      end
    end

    trait :with_beneficiary do
      beneficiary do
        create(:beneficiary,
               currency: currency,
               member: member,
               state: :active)
      end
      rid { nil }
    end

    currency { Currency.find(:btc) }
    member { create(:member, :level_3) }
    rid { Faker::Blockchain::Bitcoin.address }
    sum { 10.to_d }
    type { 'Withdraws::Coin' }
    blockchain_key { 'btc-testnet' }
  end

  factory :eth_withdraw, class: Withdraws::Coin do
    currency { Currency.find(:eth) }
    member { create(:member, :level_3) }
    rid { Faker::Blockchain::Bitcoin.address }
    sum { 10.to_d }
    type { 'Withdraws::Coin' }
    blockchain_key { 'eth-rinkeby' }

    trait :with_beneficiary do
      beneficiary do
        create(:beneficiary,
               currency: currency,
               member: member,
               state: :active)
      end
      rid { nil }
    end
  end

  factory :usd_withdraw, class: Withdraws::Fiat do

    # We need to have valid Liability-based balance to spend funds.
    trait :with_deposit_liability do
      before(:create) do |withdraw|
        create(:deposit_usd, member: withdraw.member, amount: withdraw.sum)
          .accept!
      end
    end

    trait :with_beneficiary do
      beneficiary do
        create(:beneficiary,
               currency: currency,
               member: member,
               state: :active)
      end
      rid { nil }
    end

    member { create(:member, :level_3) }
    currency { Currency.find(:usd) }
    rid { Faker::Bank.iban }
    sum { 1000.to_d }
    type { 'Withdraws::Fiat' }
    blockchain_key { 'fiat' }
  end
end
