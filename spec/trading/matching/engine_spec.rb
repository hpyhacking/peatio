# encoding: UTF-8
# frozen_string_literal: true

describe Matching::Engine do
  Order.define_method(:to_matching_mock) do
    if ord_type.to_sym == :limit
      Matching.mock_limit_order(to_matching_attributes)
    else
      Matching.mock_market_order(to_matching_attributes)
    end
  end

  let(:market) { Market.find('btcusd') }
  let(:price)  { 10.to_d }
  let(:volume) { 5.to_d }
  let(:ask)    { Matching.mock_limit_order(type: :ask, price: price, volume: volume) }
  let(:bid)    { Matching.mock_limit_order(type: :bid, price: price, volume: volume) }

  let(:orderbook) { Matching::OrderBookManager.new('btcusd', broadcast: false) }
  subject         { Matching::Engine.new(market, mode: :run) }
  before          { subject.stubs(:orderbook).returns(orderbook) }

  context 'submit market order 2' do
    subject { Matching::Engine.new(market, mode: :dryrun) }

    context 'sell market order 1' do
      # We have the next state of bid(buy) order book.
      # | price | volume |
      # | 0.86  | 0.9817 |
      #
      # Ask market order for 0.918 BTC was created.
      # We expect order to be fully executed.
      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :limit,
               locked: 0.844262.to_d,
               price: 0.86.to_d,
               volume: 0.9817.to_d)
      end

      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               ord_type: :market,
               locked: 0.918.to_d,
               price: nil,
               volume: 0.918.to_d)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            {
              :action => "execute",
              :trade => {
                :market_id=>"btcusd",
                :maker_order_id=>bid1_in_db.id,
                :taker_order_id=>ask1_in_db.id,
                :strike_price=>0.86.to_d,
                :amount=>0.918.to_d,
                :total=>0.78948.to_d
              }
            },
            { persistent: false }
          ]
        ]
      end

      it 'publish trade' do
        subject.submit bid1_in_db.to_matching_mock
        subject.submit ask1_in_db.to_matching_mock
        expect(subject.queue).to eq expected_messages
      end
    end

    context 'sell market order 2' do
      # We have the next state of bid(buy) order book.
      # | price | volume |
      # | 8.6   | 0.9817 |
      #
      # Ask market order for 0.918 BTC was created.
      # We expect order to be fully executed.
      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :limit,
               locked: 8.44262.to_d,
               price: 8.6.to_d,
               volume: 0.9817.to_d)
      end

      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               ord_type: :market,
               locked: 0.918.to_d,
               price: nil,
               volume: 0.918.to_d)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            {
              :action => "execute",
              :trade => {
                :market_id=>"btcusd",
                :taker_order_id=>ask1_in_db.id,
                :maker_order_id=>bid1_in_db.id,
                :strike_price=>8.6.to_d,
                :amount=>0.918.to_d,
                :total=>7.8948.to_d
              }
            },
            { persistent: false }
          ]
        ]
      end

      it 'publish trade' do
        subject.submit bid1_in_db.to_matching_mock
        subject.submit ask1_in_db.to_matching_mock
        expect(subject.queue).to eq expected_messages
      end
    end

    context 'market order out of locked 1' do
      # We have the next state of ask(sell) order book.
      # | price | volume |
      # | 0.8006| 0.9817 |
      #
      # Bid market order for 0.8395 BTC was created with 0.6716 USD locked
      # (estimated average price is 0.8). But orderbook state changed and order doesn't
      # have enough locked to match with first in orderbook.
      # We expect order to be cancelled.
      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               price: 80.06.to_d,
               volume: 0.9817.to_d)
      end

      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 67.16.to_d,
               price: nil,
               volume: 0.8395.to_d)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            {
              :action=>"cancel",
              :order=>
                {:id=>bid1_in_db.id,
                 :timestamp=>bid1_in_db.created_at.to_i,
                 :type=>:bid,
                 :locked=>67.16.to_d,
                 :volume=>0.8395.to_d,
                 :market=>"btcusd",
                 :ord_type=>"market"}
            },
            {:persistent=>false}
          ]
        ]
      end
      it 'publish cancel order' do
        subject.submit ask1_in_db.to_matching_mock
        subject.submit bid1_in_db.to_matching_mock
        expect(subject.queue).to eq expected_messages
      end
    end

    context 'market order out of locked 2' do
      # We have the next state of ask(sell) order book.
      # | price | volume |
      # | 0.8006| 0.0111 |
      # | 1.4117| 0.9346 |
      #
      # Bid market order for 0.8395 BTC was created with 0.47237199 USD locked
      # (estimated average price is 0.562682).
      # But orderbook state changed and order doesn't have enough locked to
      # fulfill. We expect order to be partially filled and then cancelled.
      # For full order execution we need 1.181463512078
      # (0.0111 * 0.8006 + 0.83061334 * 1.4117). Which is less then locked.
      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               price: 80.06.to_d,
               volume: 0.0111.to_d)
      end

      let!(:ask2_in_db) do
        create(:order_ask,
               :btcusd,
               price: 141.17.to_d,
               volume: 0.9346.to_d)
      end

      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 47.237199.to_d,
               price: nil,
               volume: 0.8395.to_d)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            {
              :action => "execute",
              :trade => {
                :market_id=>"btcusd",
                :maker_order_id=>ask1_in_db.id,
                :taker_order_id=>bid1_in_db.id,
                :strike_price=>80.06.to_d,
                :amount=>0.0111.to_d,
                :total=>0.888666.to_d
              }
            },
            { persistent: false }
          ],
          [
            :trade_executor,
            {
              :action=>"cancel",
              :order=>
                {:id=>bid1_in_db.id,
                 :timestamp=>bid1_in_db.created_at.to_i,
                 :type=>:bid,
                 :locked=>46.348533.to_d,
                 :volume=>0.8284.to_d,
                 :market=>"btcusd",
                 :ord_type=>"market"}
            },
           {:persistent=>false}
          ]
        ]
      end
      it 'publish single trade and cancel order' do
        subject.submit ask1_in_db.to_matching_mock
        subject.submit ask2_in_db.to_matching_mock
        subject.submit bid1_in_db.to_matching_mock
        expect(subject.queue).to eq expected_messages
      end
    end

    context 'market order out of locked 3' do
      # We have the next state of ask(sell) order book.
      # | price | volume |
      # | 3000.0| 0.0009 |
      # | 3001.0| 0.0011 |
      # | 3010.0| 0.1000 |
      #
      # Bid market order for 0.01 BTC was created with 30.03 USD locked
      # (estimated average price is 3003).
      # But orderbook state changed and order doesn't have enough locked to
      # fulfill. We expect order to create two trades and then cancel.
      # For full order execution we need 30.0811
      # (3000 * 0.0009 + 3001 * 0.0011 + 3010 * 0.008).
      # Which is less then locked.
      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               price: 3000.to_d,
               volume: 0.0009.to_d)
      end

      let!(:ask2_in_db) do
        create(:order_ask,
               :btcusd,
               price: 3001.to_d,
               volume: 0.0011.to_d)
      end

      let!(:ask3_in_db) do
        create(:order_ask,
               :btcusd,
               price: 3010.to_d,
               volume: 0.1000.to_d)
      end

      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 30.03.to_d,
               price: nil,
               volume: 0.01.to_d)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            { :action => "execute",
              :trade => {
                :market_id=>"btcusd",
                :maker_order_id=>ask1_in_db.id,
                :taker_order_id=>bid1_in_db.id,
                :strike_price=>0.3e4,
                :amount=>0.9e-3,
                :total=>0.27e1
            }},
            { :persistent=>false }
          ],
          [
            :trade_executor,
            { :action => "execute",
              :trade => {
                :market_id=>"btcusd",
                :maker_order_id=>ask2_in_db.id,
                :taker_order_id=>bid1_in_db.id,
                :strike_price=>0.3001e4,
                :amount=>0.11e-2,
                :total=>0.33011e1
            }},
            { :persistent=>false }
          ],
          [
            :trade_executor,
            { :action=>"cancel",
              :order=> {
                :id=>bid1_in_db.id,
                :timestamp=>bid1_in_db.created_at.to_i,
                :type=>:bid,
                :locked=>0.240289e2,
                :volume=>0.8e-2,
                :market=>"btcusd",
                :ord_type=>"market"
            }},
            { :persistent=>false }
          ]
        ]
      end
      it 'publish single two trades and cancel order' do
        subject.submit ask1_in_db.to_matching_mock
        subject.submit ask2_in_db.to_matching_mock
        subject.submit bid1_in_db.to_matching_mock
        expect(subject.queue).to eq expected_messages
      end
    end

    context 'market doesn\'t have enough funds 1' do
      # We have the next state of ask(sell) order book.
      # | price | volume |
      # | 3000.0| 0.0009 |
      #
      # Bid market order for 0.001 BTC was created with 30.03 USD locked
      # (estimated average price is 3003).
      # But orderbook state changed and market doesn't have enough volume to
      # fulfill. We expect order to match with the first opposite order and then
      # be cancelled.
      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               price: 3000.to_d,
               volume: 0.0009.to_d)
      end

      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 30.03.to_d,
               price: nil,
               volume: 0.01.to_d)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            { :action => "execute",
              :trade => {
                :market_id=>"btcusd",
                :maker_order_id=>ask1_in_db.id,
                :taker_order_id=>bid1_in_db.id,
                :strike_price=>0.3e4,
                :amount=>0.9e-3,
                :total=>0.27e1
            }},
            { :persistent=>false }
          ],
          [
            :trade_executor,
            {
              :action=>"cancel",
              :order=> {
                :id=>bid1_in_db.id,
                :timestamp=>bid1_in_db.created_at.to_i,
                :type=>:bid,
                :locked=>0.2733e2,
                :volume=>0.91e-2,
                :market=>"btcusd",
                :ord_type=>"market"
              }
            },
          { :persistent=>false }
          ]
        ]
      end
      it 'publish single trade and cancel order' do
        subject.submit ask1_in_db.to_matching_mock
        subject.submit bid1_in_db.to_matching_mock
        expect(subject.queue).to eq expected_messages
      end
    end

    context 'market doesn\'t have enough funds 2' do
      # We have the next state of ask(sell) order book.
      # | price | volume |
      # | 3000.0| 0.0009 |
      #
      # 1. Bid market order for 0.00045 BTC was created with 1.35 USD locked
      # (estimated average price is 3000).
      # 2. Bid market order for 0.0009 BTC was created with 2.7 USD locked
      # (estimated average price is 3000).
      # Firs order match fully. Second order match partially and cancel.
      let!(:ask1_in_db) do
        create(:order_ask,
               :btcusd,
               price: 3000.to_d,
               volume: 0.0009.to_d)
      end

      let!(:bid1_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 1.35.to_d,
               price: nil,
               volume: 0.00045.to_d)
      end

      let!(:bid2_in_db) do
        create(:order_bid,
               :btcusd,
               ord_type: :market,
               locked: 2.7.to_d,
               price: nil,
               volume: 0.0009.to_d)
      end

      let(:expected_messages) do
        [
          [
            :trade_executor,
            { :action => "execute",
              :trade => {
                :market_id => "btcusd",
                :maker_order_id => ask1_in_db.id,
                :taker_order_id => bid1_in_db.id,
                :strike_price => 0.3e4.to_d,
                :amount => 0.45e-3.to_d,
                :total => 0.135e1.to_d
            }},
            { :persistent => false }
          ],
          [
            :trade_executor,
            {
              :action => "execute",
              :trade => {
                :market_id => "btcusd",
                :maker_order_id => ask1_in_db.id,
                :taker_order_id => bid2_in_db.id,
                :strike_price => 0.3e4.to_d,
                :amount => 0.45e-3.to_d,
                :total => 0.135e1.to_d
              }
            },
            { :persistent => false }
          ],
          [
            :trade_executor,
            {
              :action => "cancel",
              :order => {
                :id => bid2_in_db.id,
                :timestamp => bid2_in_db.created_at.to_i,
                :type => :bid,
                :locked => 0.135e1.to_d,
                :volume => 0.45e-3.to_d,
                :market => "btcusd",
                :ord_type => "market"
              }
            },
            { :persistent => false }
          ]
        ]
      end
      it 'publish single two trades and cancel order' do
        subject.submit ask1_in_db.to_matching_mock
        subject.submit bid1_in_db.to_matching_mock
        subject.submit bid2_in_db.to_matching_mock
        expect(subject.queue).to eq expected_messages
      end
    end
  end

  context 'submit market order' do
    let!(:bid)  { Matching.mock_limit_order(type: :bid, price: '0.1'.to_d, volume: '0.1'.to_d) }
    let!(:ask1) { Matching.mock_limit_order(type: :ask, price: '1.0'.to_d, volume: '1.0'.to_d) }
    let!(:ask2) { Matching.mock_limit_order(type: :ask, price: '2.0'.to_d, volume: '1.0'.to_d) }
    let!(:ask3) { Matching.mock_limit_order(type: :ask, price: '3.0'.to_d, volume: '1.0'.to_d) }

    it 'should fill the market order completely' do
      mo = Matching.mock_market_order(type: :bid, locked: '6.0'.to_d, volume: '2.4'.to_d)

      AMQP::Queue.expects(:enqueue).with(:trade_executor, { action: "execute", trade: { market_id: market.id, maker_order_id: ask1.id, taker_order_id: mo.id, strike_price: ask1.price, amount: ask1.volume, total: '1.0'.to_d } }, anything)
      AMQP::Queue.expects(:enqueue).with(:trade_executor, { action: "execute", trade: { market_id: market.id, maker_order_id: ask2.id, taker_order_id: mo.id, strike_price: ask2.price, amount: ask2.volume, total: '2.0'.to_d } }, anything)
      AMQP::Queue.expects(:enqueue).with(:trade_executor, { action: "execute", trade: { market_id: market.id, maker_order_id: ask3.id, taker_order_id: mo.id, strike_price: ask3.price, amount: '0.4'.to_d, total: '1.2'.to_d } }, anything)

      subject.submit bid
      subject.submit ask1
      subject.submit ask2
      subject.submit ask3
      subject.submit mo

      expect(subject.ask_orders.limit_orders.size).to eq 1
      expect(subject.ask_orders.limit_orders.values.first).to eq [ask3]
      expect(ask3.volume).to eq '0.6'.to_d

      expect(subject.bid_orders.market_orders).to be_empty
    end

    it 'should fill the market order partially and cancel it' do
      mo = Matching.mock_market_order(type: :bid, locked: '6.0'.to_d, volume: '2.4'.to_d)

      AMQP::Queue.expects(:enqueue).with(:trade_executor, { action: "execute", trade: { market_id: market.id, maker_order_id: ask1.id, taker_order_id: mo.id, strike_price: ask1.price, amount: ask1.volume, total: '1.0'.to_d } }, anything)
      AMQP::Queue.expects(:enqueue).with(:trade_executor, { action: "execute", trade: { market_id: market.id, maker_order_id: ask2.id, taker_order_id: mo.id, strike_price: ask2.price, amount: ask2.volume, total: '2.0'.to_d } }, anything)
      AMQP::Queue.expects(:enqueue).with(:trade_executor, has_entries(action: 'cancel', order: has_entry(id: mo.id)), anything)

      subject.submit bid
      subject.submit ask1
      subject.submit ask2
      subject.submit mo

      expect(subject.ask_orders.limit_orders).to be_empty
      expect(subject.bid_orders.market_orders).to be_empty
    end
  end

  context 'submit limit order' do
    context 'fully match incoming order' do
      it 'should execute trade' do
        AMQP::Queue.expects(:enqueue)
                 .with(:trade_executor, { action: "execute", trade: { market_id: market.id, maker_order_id: ask.id, taker_order_id: bid.id, strike_price: price, amount: volume, total: '50.0'.to_d } }, anything)

        subject.submit(ask)
        subject.submit(bid)

        expect(subject.ask_orders.limit_orders).to be_empty
        expect(subject.bid_orders.limit_orders).to be_empty
      end
    end

    context 'partial match incoming order' do
      let(:ask) { Matching.mock_limit_order(type: :ask, price: price, volume: 3.to_d) }

      it 'should execute trade' do
        AMQP::Queue.expects(:enqueue)
                 .with(:trade_executor, { action: "execute", trade: { market_id: market.id, maker_order_id: ask.id, taker_order_id: bid.id, strike_price: price, amount: 3.to_d, total: '30.0'.to_d } }, anything)

        subject.submit(ask)
        subject.submit(bid)

        expect(subject.ask_orders.limit_orders).to be_empty
        expect(subject.bid_orders.limit_orders).not_to be_empty

        AMQP::Queue.expects(:enqueue)
                 .with(:trade_executor, { action: 'cancel', order: bid.attributes }, anything)
        subject.cancel(bid)
        expect(subject.bid_orders.limit_orders).to be_empty
      end
    end

    context 'match order with many counter orders' do
      let(:bid)    { Matching.mock_limit_order(type: :bid, price: price, volume: 10.to_d) }

      let(:asks) do
        [nil, nil, nil].map do
          Matching.mock_limit_order(type: :ask, price: price, volume: 3.to_d)
        end
      end

      it 'should execute trade' do
        AMQP::Queue.expects(:enqueue).times(asks.size)

        asks.each { |ask| subject.submit(ask) }
        subject.submit(bid)

        expect(subject.ask_orders.limit_orders).to be_empty
        expect(subject.bid_orders.limit_orders).not_to be_empty
      end
    end

    context 'fully match order after some cancellatons' do
      let(:bid)      { Matching.mock_limit_order(type: :bid, price: price, volume: 10.to_d) }
      let(:low_ask)  { Matching.mock_limit_order(type: :ask, price: price - 1, volume: 3.to_d) }
      let(:high_ask) { Matching.mock_limit_order(type: :ask, price: price, volume: 3.to_d) }

      it 'should match bid with high ask' do
        subject.submit(low_ask) # low ask enters first
        subject.submit(high_ask)
        subject.cancel(low_ask) # but it's canceled

        AMQP::Queue.expects(:enqueue)
                 .with(:trade_executor, { action: "execute", trade: { market_id: market.id, maker_order_id: high_ask.id, taker_order_id: bid.id, strike_price: high_ask.price, amount: high_ask.volume, total: '30.0'.to_d } }, anything)
        subject.submit(bid)

        expect(subject.ask_orders.limit_orders).to be_empty
        expect(subject.bid_orders.limit_orders).not_to be_empty
      end
    end
  end

  context '#cancel' do
    it 'should cancel order' do
      subject.submit(ask)
      subject.cancel(ask)
      expect(subject.ask_orders.limit_orders).to be_empty

      subject.submit(bid)
      subject.cancel(bid)
      expect(subject.bid_orders.limit_orders).to be_empty
    end
  end

  context 'dryrun' do
    subject { Matching::Engine.new(market, mode: :dryrun) }

    it 'should not publish matched trades' do
      AMQP::Queue.expects(:enqueue).never

      subject.submit(ask)
      subject.submit(bid)

      expect(subject.ask_orders.limit_orders).to be_empty
      expect(subject.bid_orders.limit_orders).to be_empty

      expect(subject.queue.size).to eq 1
      expect(subject.queue.first).to eq [:trade_executor, { action: "execute", trade: { market_id: market.id, maker_order_id: ask.id, taker_order_id: bid.id, strike_price: price, amount: volume, total: '50.0'.to_d } }, { persistent: false }]
    end
  end

  context 'publish_increment' do
    before(:each) { subject.initializing = false }

    it 'should publish increment of orderbook' do
      ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-inc", { "asks" => ["10.0", "5.0"], "sequence" => 2, })
      ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-inc", { "bids" => ["10.0", "5.0"], "sequence" => 3, })

      subject.publish_increment(market.id, :ask, ask.price, ask.volume)
      subject.publish_increment(market.id, :bid, bid.price, bid.volume)
    end
  end

  context 'publish_snapshot' do
    let(:ask1)    { Matching.mock_limit_order(type: :ask, price: "14".to_d, volume: "1.0".to_d) }
    let(:ask2)    { Matching.mock_limit_order(type: :ask, price: "12".to_d, volume: "1.0".to_d) }
    let(:bid1)    { Matching.mock_limit_order(type: :bid, price: "11".to_d, volume: "2.0".to_d) }
    let(:bid2)    { Matching.mock_limit_order(type: :bid, price: "10".to_d, volume: "2.0".to_d) }

    it 'should publish snapshot of orderbook' do
      subject.submit(ask1)
      subject.submit(ask2)
      subject.submit(bid1)
      subject.submit(bid2)

      ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-snap", {
        "asks" => [["12.0", "1.0"], ["14.0", "1.0"]],
        "bids" => [["11.0", "2.0"], ["10.0", "2.0"]],
        "sequence" => 1,
      })
      subject.publish_snapshot
    end

    context 'periodic publish snapshot time' do
      before(:each) { subject.initializing = false }

      it 'should publish snapshot of orderbook and set increment_count to 1' do
        subject.snapshot_time = Time.now - 80.second
        subject.submit(ask1)
        subject.submit(bid1)
        ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-snap", {
          "asks" => [["14.0", "1.0"]],
          "bids" => [["11.0", "2.0"]],
          "sequence" => 1,
        })
        ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-inc", { "asks" => ["11.0", "2.0"], "sequence" => 2 })
        subject.publish_increment(market.id, :ask, bid1.price, bid1.volume)
        expect(subject.increment_count).to eq(1)
      end

      it 'should publish snapshot of orderbook (snapshot_time >= 1m and increment count < 20)' do
        subject.snapshot_time = Time.now - 80.second
        subject.submit(ask1)
        subject.submit(bid1)
        ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-snap", {
          "asks" => [["14.0", "1.0"]],
          "bids" => [["11.0", "2.0"]],
          "sequence" => 1,
        })
        ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-inc", { "asks" => ["11.0", "2.0"], "sequence" => 2 })
        subject.publish_increment(market.id, :ask, bid1.price, bid1.volume)
      end

      it 'should publish snapshot of orderbook (snapshot_time > 10s and increment count => 20)' do
        subject.snapshot_time = Time.now - 11.second
        subject.increment_count = 20
        subject.submit(ask1)
        subject.submit(bid1)
        ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-snap", {
          "asks" => [["14.0", "1.0"]],
          "bids" => [["11.0", "2.0"]],
          "sequence" => 1
        })
        ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-inc", { "asks" => ["11.0", "2.0"], "sequence" => 2 })
        subject.publish_increment(market.id, :ask, bid1.price, bid1.volume)
      end

      it 'shouldnt publish snapshot of orderbook (snapshot_time <= 1m and increment count < 20)' do
        subject.snapshot_time = Time.now
        subject.submit(ask1)
        subject.submit(bid1)
        ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-snap", {
          "asks" => [["14.0", "1.0"]],
          "bids" => [["11.0", "2.0"]],
          "sequence" => 1
        }).never
        ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-inc", { "asks" => ["11.0", "2.0"], "sequence" => 2 })
        subject.publish_increment(market.id, :ask, bid1.price, bid1.volume)
      end

      it 'shouldnt publish snapshot of orderbook (snapshot_time < 10s and increment count => 20)' do
        subject.snapshot_time = Time.now - 1.second
        subject.increment_count = 20
        subject.submit(ask1)
        subject.submit(bid1)
        ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-snap", {
          "asks" => [["14.0", "1.0"]],
          "bids" => [["11.0", "2.0"]],
        }).never
        ::AMQP::Queue.expects(:enqueue_event).with("public", market.id, "ob-inc", { "asks" => ["11.0", "2.0"], "sequence" => 2 })
        subject.publish_increment(market.id, :ask, bid1.price, bid1.volume)
      end
    end
  end
end
