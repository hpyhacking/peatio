# encoding: UTF-8
# frozen_string_literal: true

describe Serializers::EventAPI::OrderCompleted do
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
  let(:completed_at) { Time.current }

  before do
    seller.ac(:btc).plus_funds('100.0'.to_d)
    seller.ac(:btc).lock_funds('100.0'.to_d)
  end

  before { OrderAsk.any_instance.expects(:created_at).returns(created_at).at_least_once }
  before { OrderAsk.any_instance.expects(:updated_at).returns(completed_at).at_least_once }

  before do
    DatabaseCleaner.clean
    EventAPI.expects(:notify).with('market.btcusd.order_created', anything).once
    EventAPI.expects(:notify).with('market.btcusd.order_completed', {
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
      current_income_amount:   '0.0',
      previous_income_amount:  '3.0',
      initial_outcome_amount:  '100.0',
      current_outcome_amount:  '0.0',
      previous_outcome_amount: '100.0',
      strategy:                'limit',
      price:                   '0.03',
      state:                   'completed',
      trades_count:            1,
      created_at:              created_at.iso8601,
      completed_at:            completed_at.iso8601
    }).once
  end

  after do
    DatabaseCleaner.strategy = :truncation
  end

  it 'publishes event', clean_database_with_truncation: true do
    subject.update! \
    volume:         0,
    locked:         0,
    funds_received: 100,
    trades_count:   1,
    state:          Order::DONE
  end
end
