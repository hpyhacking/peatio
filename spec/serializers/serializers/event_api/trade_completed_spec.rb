# encoding: UTF-8
# frozen_string_literal: true

describe Serializers::EventAPI::TradeCompleted, 'Event API' do
  let(:seller) { create(:member, :level_3, :barong) }

  let(:buyer) { create(:member, :level_3, :barong) }

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
      member:        seller
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
      member:        buyer
  end

  let(:completed_at) { Time.current }

  let :executor do
    ask = Matching::LimitOrder.new(order_ask.to_matching_attributes)
    bid = Matching::LimitOrder.new(order_bid.to_matching_attributes)
    Matching::Executor.new \
      market_id:    :btcusd,
      ask_id:       ask.id,
      bid_id:       bid.id,
      strike_price: '0.03',
      volume:       '14.0',
      funds:        '0.42'
  end

  subject { executor.execute! }

  before do
    seller.ac(:btc).plus_funds('100.0'.to_d)
    seller.ac(:btc).lock_funds('100.0'.to_d)
  end

  before do
    buyer.ac(:usd).plus_funds('100.0'.to_d)
    buyer.ac(:usd).lock_funds('14.0'.to_d)
  end

  before { Trade.any_instance.expects(:created_at).returns(completed_at).at_least_once }

  before do
    EventAPI.expects(:notify).with('market.btcusd.order_created', anything).twice
    EventAPI.expects(:notify).with('market.btcusd.order_updated', anything).once
    EventAPI.expects(:notify).with('market.btcusd.order_completed', anything).once
    EventAPI.expects(:notify).with('market.btcusd.trade_completed', {
      market:                'btcusd',
      price:                 '0.03',
      buyer_uid:             buyer.uid,
      buyer_income_unit:     'btc',
      buyer_income_amount:   '14.0',
      buyer_income_fee:      '0.021',
      buyer_outcome_unit:    'usd',
      buyer_outcome_amount:  '0.42',
      buyer_outcome_fee:     '0.0',
      seller_uid:            seller.uid,
      seller_income_unit:    'usd',
      seller_income_amount:  '0.42',
      seller_income_fee:     '0.00063',
      seller_outcome_unit:   'btc',
      seller_outcome_amount: '14.0',
      seller_outcome_fee:    '0.0',
      completed_at:          completed_at.iso8601
    }).once
  end

  it 'publishes event' do
    subject
    expect(order_bid.reload.state).to eq 'done'
    expect(order_ask.reload.state).to eq 'wait'
  end
end
