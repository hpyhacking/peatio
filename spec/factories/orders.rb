# encoding: UTF-8
# frozen_string_literal: true

FactoryBot.define do
  factory :order_bid do

    # Create liability history by passing with_deposit_liability trait.
    trait :with_deposit_liability do
      before(:create) do |order|
        deposit = create(:deposit_usd, member: order.member, amount: order.locked)
        deposit.accept!
        deposit.process!
        deposit.dispatch!
      end

      bid { :usd }
      ask { :btc }
      market { Market.find(:btcusd) }
      state { :wait }
      ord_type { 'limit' }
      price { '1'.to_d }
      volume { '1'.to_d }
      origin_volume { volume.to_d }
      locked { price.to_d *  volume.to_d }
      origin_locked { locked.to_d }
      member { create(:member) }
    end

    trait :btcusd do
      bid { :usd }
      ask { :btc }
      market { Market.find(:btcusd) }
      state { :wait }
      ord_type { 'limit' }
      price { '1'.to_d }
      volume { '1'.to_d }
      origin_volume { volume.to_d }
      locked { price.to_d *  volume.to_d }
      origin_locked { locked.to_d }
      member { create(:member) }
    end

    trait :btceth do
      bid { :eth }
      ask { :btc }
      market { Market.find(:btceth) }
      state { :wait }
      ord_type { 'limit' }
      price { '1'.to_d }
      volume { '1'.to_d }
      origin_volume { volume.to_d }
      locked { price.to_d *  volume.to_d }
      origin_locked { locked.to_d }
      member { create(:member) }
    end
  end

  factory :order_ask do

    # Create liability history by passing with_deposit_liability trait.
    trait :with_deposit_liability do
      before(:create) do |order|
        deposit = create(:deposit_btc, member: order.member, amount: order.locked)
        deposit.accept!
        deposit.process!
        deposit.dispatch!
      end

      bid { :usd }
      ask { :btc }
      market { Market.find(:btcusd) }
      state { :wait }
      ord_type { 'limit' }
      price { '1'.to_d }
      volume { '1'.to_d }
      origin_volume { volume.to_d }
      locked { volume.to_d }
      origin_locked { locked.to_d }
      member { create(:member) }
    end

    trait :btcusd do
      bid { :usd }
      ask { :btc }
      market { Market.find(:btcusd) }
      state { :wait }
      ord_type { 'limit' }
      price { '1'.to_d }
      volume { '1'.to_d }
      origin_volume { volume.to_d }
      locked { volume.to_d }
      origin_locked { locked.to_d }
      member { create(:member) }
    end

    trait :btceth do
      bid { :eth }
      ask { :btc }
      market { Market.find(:btceth) }
      state { :wait }
      ord_type { 'limit' }
      price { '1'.to_d }
      volume { '1'.to_d }
      origin_volume { volume.to_d }
      locked { volume.to_d }
      origin_locked { locked.to_d }
      member { create(:member) }
    end
  end
end
