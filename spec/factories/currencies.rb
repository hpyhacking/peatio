# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :currency do
    trait :usd do
      code                 { 'usd' }
      name                 { 'US Dollar' }
      type                 { 'fiat' }
      precision            { 2 }
    end

    trait :eur do
      code                 { 'eur' }
      name                 { 'Euro' }
      type                 { 'fiat' }
      precision            { 8 }
      status               { 'disabled' }
    end

    trait :btc do
      code                 { 'btc' }
      name                 { 'Bitcoin' }
      type                 { 'coin' }
    end

    trait :eth do
      code                 { 'eth' }
      name                 { 'Ethereum' }
      type                 { 'coin' }
    end

    trait :trst do
      code                 { 'trst' }
      name                 { 'WeTrust' }
      type                 { 'coin' }
    end

    trait :tom do
      code                 { 'tom' }
      name                 { 'TOM' }
      type                 { 'coin' }
    end

    trait :ring do
      code                 { 'ring' }
      name                 { 'Evolution Land Global Token' }
      type                 { 'coin' }
    end

    trait :fake do
      code                { 'fake' }
      name                { 'Fake Coin' }
      type                { 'coin' }
    end

    trait :xagm_cx do
      code                { 'xagm.cx' }
      name                { 'XAGm.cx' }
      type                { 'coin' }
    end
  end
end
