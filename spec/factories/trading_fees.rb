# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  sequence(:fee) do
    Kernel.rand(TradingFee::MIN_FEE..TradingFee::MAX_FEE).to_d
  end

  sequence(:group) do |n|
    "vip-#{n}"
  end

  factory :trading_fee do
    maker { generate(:fee) }
    taker { generate(:fee) }
    group { generate(:group) }

    trait :with_market do
      market { Market.all.sample }
    end
  end
end
