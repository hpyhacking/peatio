# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :operation do
    currency { Currency.all.sample }

    credit { Kernel.rand(10..1000).to_d }

    trait :debit do
      debit { Kernel.rand(10..1000).to_d }
      credit { 0 }
    end

  end

  factory :asset, class: Operations::Asset, parent: :operation do
    code do
      Operations::Chart.code_for(type: :asset,
                                 currency_type: currency.type)
    end
  end

  factory :expense, class: Operations::Expense, parent: :operation do
    code do
      Operations::Chart.code_for(type: :expense,
                                 currency_type: currency.type)
    end
  end

  factory :revenue, class: Operations::Revenue, parent: :operation do
    code do
      Operations::Chart.code_for(type: :revenue,
                                 currency_type: currency.type)
    end
  end

  factory :liability, class: Operations::Liability, parent: :operation do
    code do
      Operations::Chart.code_for(type: :liability,
                                 currency_type: currency.type,
                                 kind: :main)
    end
    member { create(:member, :level_3) }

    # Update legacy balance.
    after(:create) do |liability|
      acc = liability.member.ac(liability.currency)
      acc.plus_funds(liability.credit) unless liability.credit.zero?
      acc.sub_funds(liability.debit) unless liability.debit.zero?
    end
  end
end
