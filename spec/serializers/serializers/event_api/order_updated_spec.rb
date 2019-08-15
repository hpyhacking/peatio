# encoding: UTF-8
# frozen_string_literal: true

describe Serializers::EventAPI::OrderUpdated, OrderAsk do
  let(:seller) { create(:member, :level_3, :barong) }

  let :order_ask do
    # Sell 100 BTC for 3 USD (0.03 USD per BTC).
    create :order_ask, \
      bid:           :usd,
      ask:           :btc,
      market:        Market.find(:btcusd),
      state:         :wait,
      ord_type:      :limit,
      price:         '0.03'.to_d,
      volume:        '100.0',
      origin_volume: '100.0',
      locked:        '100.0',
      origin_locked: '100.0',
      member:        seller
  end

  subject { order_ask }

  let(:created_at) { 10.minutes.ago }
  let(:updated_at) { Time.current }

  before do
    seller.ac(:btc).plus_funds('100.0'.to_d)
    seller.ac(:btc).lock_funds('100.0'.to_d)
  end

  before { OrderAsk.any_instance.expects(:created_at).returns(created_at).at_least_once }
  before { OrderAsk.any_instance.expects(:updated_at).returns(updated_at).at_least_once }

  before do
    DatabaseCleaner.clean
    EventAPI.expects(:notify).with('market.btcusd.order_created', anything)
    EventAPI.expects(:notify).with('market.btcusd.order_updated', {
      id:                      1,
      market:                  'btcusd',
      type:                    'sell',
      trader_uid:              seller.uid,
      income_unit:             'usd',
      income_fee_type:         'relative',
      income_maker_fee_value:  '0.0015',
      income_taker_fee_value:  '0.0015',
      outcome_unit:            'btc',
      outcome_fee_type:        'relative',
      outcome_fee_value:       '0.0',
      initial_income_amount:   '3.0',
      current_income_amount:   '2.4',
      previous_income_amount:  '3.0',
      initial_outcome_amount:  '100.0',
      current_outcome_amount:  '80.0',
      previous_outcome_amount: '100.0',
      strategy:                'limit',
      price:                   '0.03',
      state:                   'open',
      trades_count:            1,
      created_at:              created_at.iso8601,
      updated_at:              updated_at.iso8601
    }).once
  end

  after do
    DatabaseCleaner.strategy = :truncation
  end

  it 'publishes event', clean_database_with_truncation: true do
    subject.transaction do
      subject.update! \
        volume:         80,
        locked:         80,
        funds_received: 20,
        trades_count:   1
    end
  end
end

describe Serializers::EventAPI::OrderUpdated, OrderBid do
  let(:buyer) { create(:member, :level_3, :barong) }

  let :order_bid do
    # Buy 14 BTC for 0.42 USD (0.03 USD per BTC).
    create :order_bid, \
      bid:           :usd,
      ask:           :btc,
      market:        Market.find(:btcusd),
      state:         :wait,
      ord_type:      :limit,
      price:         '0.03'.to_d,
      volume:        '14.0',
      origin_volume: '14.0',
      locked:        '0.42',
      origin_locked: '0.42',
      member:        buyer
  end

  subject { order_bid }

  let(:created_at) { 10.minutes.ago }
  let(:updated_at) { Time.current }

  before do
    buyer.ac(:btc).plus_funds('100.0'.to_d)
    buyer.ac(:btc).lock_funds('100.0'.to_d)
  end

  before { OrderBid.any_instance.expects(:created_at).returns(created_at).at_least_once }
  before { OrderBid.any_instance.expects(:updated_at).returns(updated_at).at_least_once }

  before do
    DatabaseCleaner.clean
    EventAPI.expects(:notify).with('market.btcusd.order_created', anything)
    EventAPI.expects(:notify).with('market.btcusd.order_updated', {
      id:                      1,
      market:                  'btcusd',
      type:                    'buy',
      trader_uid:              buyer.uid,
      income_unit:             'btc',
      income_fee_type:         'relative',
      income_maker_fee_value:  '0.0015',
      income_taker_fee_value:  '0.0015',
      outcome_unit:            'usd',
      outcome_fee_type:        'relative',
      outcome_fee_value:       '0.0',
      initial_income_amount:   '14.0',
      current_income_amount:   '12.0',
      previous_income_amount:  '14.0',
      initial_outcome_amount:  '0.42',
      current_outcome_amount:  '0.36',
      previous_outcome_amount: '0.42',
      strategy:                'limit',
      price:                   '0.03',
      state:                   'open',
      trades_count:            1,
      created_at:              created_at.iso8601,
      updated_at:              updated_at.iso8601
    }).once
  end

  after do
    DatabaseCleaner.strategy = :truncation
  end

  it 'publishes event', clean_database_with_truncation: true do
    subject.transaction do
      subject.update! \
        volume:         12,
        locked:         0.36,
        funds_received: 2,
        trades_count:   1
    end
  end
end
