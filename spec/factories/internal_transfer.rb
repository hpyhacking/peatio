# frozen_string_literal: true

FactoryBot.define do
  factory :internal_transfer_btc, class: InternalTransfer do
    trait :with_deposit_liability do
      before(:create) do |internal_tranfer|
        deposit = create(:deposit_btc, member: internal_tranfer.sender, amount: internal_tranfer.amount)
        deposit.accept!
        deposit.process!
        deposit.dispatch!
      end
    end

    currency { Currency.find(:btc) }
    amount { 10.to_d }
    sender { create(:member, :level_3) }
    receiver { create(:member, :level_3) }
    state { 'completed' }
  end

  factory :internal_transfer_usd, class: InternalTransfer do
    trait :with_deposit_liability do
      before(:create) do |internal_tranfer|
        create(:deposit_usd, member: internal_tranfer.sender, amount: internal_tranfer.amount)
          .accept!
      end
    end

    currency { Currency.find(:usd) }
    amount { 1000.to_d }
    sender { create(:member, :level_3) }
    receiver { create(:member, :level_3) }
    state { 'completed' }
  end
end
