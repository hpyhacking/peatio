# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  # TODO: Rename this factory to account once we drop legacy accounts.
  factory :operations_account, class: Operations::Account do
    trait '101' do
      code          { 101 }
      type          { :asset }
      kind          { :main }
      currency_type { :fiat }
      description   { 'Main Fiat Assets Account' }
      scope         { :platform }
    end

    trait '102' do
      code          { 102 }
      type          { :asset }
      kind          { :main }
      currency_type { :coin }
      description   { 'Main Crypto Assets Account' }
      scope         { :platform }
    end

    trait '201' do
      code          { 201 }
      type          { :liability }
      kind          { :main }
      currency_type { :fiat }
      description   { 'Main Fiat Liabilities Account' }
      scope         { :member }
    end

    trait '202' do
      code          { 202 }
      type          { :liability }
      kind          { :main }
      currency_type { :coin }
      description   { 'Main Crypto Liabilities Account' }
      scope         { :member }
    end

    trait '211' do
      code          { 211 }
      type          { :liability }
      kind          { :locked }
      currency_type { :fiat }
      description   { 'Locked Fiat Liabilities Account' }
      scope         { :member }
    end

    trait '212' do
      code          { 212 }
      type          { :liability }
      kind          { :locked }
      currency_type { :coin }
      description   { 'Locked Crypto Liabilities Account' }
      scope         { :member }
    end

    trait '301' do
      code          { 301 }
      type          { :revenue }
      kind          { :main }
      currency_type { :fiat }
      description   { 'Main Fiat Revenues Account' }
      scope         { :platform }
    end

    trait '302' do
      code          { 302 }
      type          { :revenue }
      kind          { :main }
      currency_type { :coin }
      description   { 'Main Crypto Revenues Account' }
      scope         { :platform }
    end

    trait '401' do
      code          { 401 }
      type          { :expense }
      kind          { :main }
      currency_type { :fiat }
      description   { 'Main Fiat Expenses Account' }
      scope         { :platform }
    end

    trait '402' do
      code          { 402 }
      type          { :expense }
      kind          { :main }
      currency_type { :coin }
      description   { 'Main Crypto Expenses Account' }
      scope         { :platform }
    end
  end
end
