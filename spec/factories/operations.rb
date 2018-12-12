# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :operation do
    currency { Currency.coins.sample }

    credit { Kernel.rand(10..1000).to_d }

    trait :debit do
      debit { Kernel.rand(10..1000).to_d }
      credit { 0 }
    end

  end

  factory :asset, class: Operations::Asset, parent: :operation do
    code { Operations::Chart.code_for(type: :asset, currency_type: :coin) }
  end

  factory :expense, class: Operations::Expense, parent: :operation do
    code { Operations::Chart.code_for(type: :expense, currency_type: :coin) }
  end

  factory :revenue, class: Operations::Revenue, parent: :operation do
    code { Operations::Chart.code_for(type: :revenue, currency_type: :coin) }

  end

  factory :liability, class: Operations::Liability, parent: :operation do
    code { Operations::Chart.code_for(type: :liability, currency_type: :coin) }
    member { create(:member, :level_3) }
  end
end
