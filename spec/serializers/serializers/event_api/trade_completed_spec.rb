# encoding: UTF-8
# frozen_string_literal: true

describe Serializers::EventAPI::TradeCompleted, 'Event API' do
  let(:maker) { create(:member, :level_3, :barong) }

  let(:taker) { create(:member, :level_3, :barong) }

  let :order_ask do
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
      member:        maker
  end

  let :order_bid do
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
      member:        taker
  end

  let(:completed_at) { Time.current }

  let :executor do
    ask = Matching::LimitOrder.new(order_ask.to_matching_attributes)
    bid = Matching::LimitOrder.new(order_bid.to_matching_attributes)
    Matching::Executor.new \
      action: 'execute',
      trade: {
        market_id:    :btcusd,
        maker_order_id:       ask.id,
        taker_order_id:       bid.id,
        strike_price: '0.03',
        amount:       '14.0',
        total:        '0.42'
      }
  end

  subject { executor.execute! }

  before do
    maker.ac(:btc).plus_funds('100.0'.to_d)
    maker.ac(:btc).lock_funds('100.0'.to_d)
  end

  before do
    taker.ac(:usd).plus_funds('100.0'.to_d)
    taker.ac(:usd).lock_funds('14.0'.to_d)
  end

  before { Trade.any_instance.expects(:created_at).returns(completed_at).at_least_once }

  before do
    DatabaseCleaner.clean
    EventAPI.expects(:notify).with('market.btcusd.order_created', anything).twice
    EventAPI.expects(:notify).with('market.btcusd.order_updated', anything).once
    EventAPI.expects(:notify).with('market.btcusd.order_completed', anything).once
    EventAPI.expects(:notify).with('market.btcusd.trade_completed', {
      id:                     1,
      market:                 'btcusd',
      price:                  '0.03',
      maker_uid:              maker.uid,
      maker_income_unit:      'btc',
      maker_income_amount:    '14.0',
      maker_income_fee:       '0.021',
      maker_outcome_unit:     'usd',
      maker_outcome_amount:   '0.42',
      maker_outcome_fee:      '0.0',
      taker_uid:              taker.uid,
      taker_income_unit:      'usd',
      taker_income_amount:    '0.42',
      taker_income_fee:       '0.00063',
      taker_outcome_unit:     'btc',
      taker_outcome_amount:   '14.0',
      taker_outcome_fee:      '0.0',
      completed_at:           completed_at.iso8601
    }).once
  end

  after do
    DatabaseCleaner.strategy = :truncation
  end

  it 'publishes event', clean_database_with_truncation: true do
    subject
    expect(order_bid.reload.state).to eq 'done'
    expect(order_ask.reload.state).to eq 'wait'
  end
end
