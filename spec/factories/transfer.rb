# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  sequence :transfer_key do
    "transfer_#{Faker::Number.unique.number(5).to_i}"
  end

  factory :transfer do
    key  { generate(:transfer_key) }
    category { Transfer::CATEGORIES.sample }
    description { "#{category} for #{Time.now.to_date}" }

    trait :with_assets do
      after(:create) do |t|
        assets_number = Faker::Number.between(1, 5).to_i
        create_list(:asset, assets_number, reference: t)
      end
    end

    trait :with_expenses do
      after(:create) do |t|
        expense_number = Faker::Number.between(1, 5).to_i
        create_list(:expense, expense_number, reference: t)
      end
    end

    trait :with_liabilities do
      after(:create) do |t|
        liabilities_number = Faker::Number.between(1, 5).to_i
        create_list(:liability, liabilities_number, :with_member, reference: t)
      end
    end

    trait :with_revenues do
      after(:create) do |t|
        revenues_number = Faker::Number.between(1, 5).to_i
        create_list(:revenue, revenues_number, reference: t)
      end
    end

    trait :with_operations do
      with_assets
      with_expenses
      with_liabilities
      with_revenues
    end

    factory :transfer_with_operations, traits: %i[with_operations]
  end
end
