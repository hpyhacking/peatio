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

    reference_type { %w[order deposit trade].sample }

    created_at { Faker::Date.between(3.days.ago, Date.today) }
  end

  factory :asset, class: Operations::Asset, parent: :operation do
    code do
      Operations::Account.find_by(type: :asset,
                                 currency_type: currency.type).code
    end
  end

  factory :expense, class: Operations::Expense, parent: :operation do
    code do
      Operations::Account.find_by(type: :expense,
                                  currency_type: currency.type).code
    end
  end

  factory :revenue, class: Operations::Revenue, parent: :operation do
    code do
      Operations::Account.find_by(type: :revenue,
                                  currency_type: currency.type).code
    end
  end

  factory :liability, class: Operations::Liability, parent: :operation do
    code do
      Operations::Account.find_by(type: :liability,
                                 currency_type: currency.type,
                                 kind: :main).code
    end
    trait :with_member do
      member { create(:member, :level_3) }

      # Update legacy balance.
      after(:create) do |liability|
        acc = liability.member.get_account(liability.currency)
        acc.plus_funds(liability.credit) unless liability.credit.zero?
        acc.sub_funds(liability.debit) unless liability.debit.zero?
      end
    end
  end
end
