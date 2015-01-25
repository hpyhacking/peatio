require 'spec_helper'

describe Worker::Matching do

  let(:alice)  { who_is_billionaire }
  let(:bob)    { who_is_billionaire }
  let(:market) { Market.find('btccny') }

  subject { Worker::Matching.new }

  context "engines" do
    it "should get all engines" do
      subject.engines.keys.should == [market.id]
    end

    it "should started all engines" do
      subject.engines.values.map(&:mode).should == [:run]
    end
  end

  context "partial match" do
    let(:existing) { create(:order_ask, price: '4001', volume: '10.0', member: alice) }

    before do
      subject.process({action: 'submit', order: existing.to_matching_attributes}, {}, {})
    end

    it "should started engine" do
      subject.engines['btccny'].mode.should == :run
    end

    it "should match part of existing order" do
      order = create(:order_bid, price: '4001', volume: '8.0', member: bob)

      AMQPQueue.expects(:enqueue)
        .with(:slave_book, {action: 'update', order: {id: existing.id, timestamp: existing.at, type: :ask, volume: '2.0'.to_d, price: existing.price, market: 'btccny', ord_type: 'limit'}}, anything)
      AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: existing.id, bid_id: order.id, strike_price: '4001'.to_d, volume: '8.0'.to_d, funds: '32008'.to_d}, anything)
      subject.process({action: 'submit', order: order.to_matching_attributes}, {}, {})
    end

    it "should match part of new order" do
      order = create(:order_bid, price: '4001', volume: '12.0', member: bob)

      AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: existing.id, bid_id: order.id, strike_price: '4001'.to_d, volume: '10.0'.to_d, funds: '40010'.to_d}, anything)
      AMQPQueue.expects(:enqueue).with(:slave_book, anything, anything).times(2)
      subject.process({action: 'submit', order: order.to_matching_attributes}, {}, {})
    end
  end

  context "complex partial match" do
    # submit  | ask price/volume | bid price/volume |
    # -----------------------------------------------
    # ask1    | 4003/3           |                  |
    # -----------------------------------------------
    # ask2    | 4002/3, 4003/3   |                  |
    # -----------------------------------------------
    # bid3    |                  | 4003/2           |
    # -----------------------------------------------
    # ask4    | 4002/3           |                  |
    # -----------------------------------------------
    # bid5    |                  |                  |
    # -----------------------------------------------
    # bid6    |                  | 4001/5           |
    # -----------------------------------------------
    let!(:ask1) { create(:order_ask, price: '4003', volume: '3.0', member: alice) }
    let!(:ask2) { create(:order_ask, price: '4002', volume: '3.0', member: alice) }
    let!(:bid3) { create(:order_bid, price: '4003', volume: '8.0', member: bob) }
    let!(:ask4) { create(:order_ask, price: '4002', volume: '5.0', member: alice) }
    let!(:bid5) { create(:order_bid, price: '4003', volume: '3.0', member: bob) }
    let!(:bid6) { create(:order_bid, price: '4001', volume: '5.0', member: bob) }

    let!(:orderbook) { Matching::OrderBookManager.new('btccny', broadcast: false) }
    let!(:engine)    { Matching::Engine.new(market, mode: :run) }

    before do
      engine.stubs(:orderbook).returns(orderbook)
      ::Matching::Engine.stubs(:new).returns(engine)
    end

    it "should create many trades" do
      AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: ask1.id, bid_id: bid3.id, strike_price: ask1.price, volume: ask1.volume, funds: '12009'.to_d}, anything).once
      AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: ask2.id, bid_id: bid3.id, strike_price: ask2.price, volume: ask2.volume, funds: '12006'.to_d}, anything).once
      AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: ask4.id, bid_id: bid3.id, strike_price: bid3.price, volume: '2.0'.to_d, funds: '8006'.to_d}, anything).once
      AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: ask4.id, bid_id: bid5.id, strike_price: ask4.price, volume: bid5.volume, funds: '12006'.to_d}, anything).once

      subject
    end
  end

  context "cancel order" do
    let(:existing) { create(:order_ask, price: '4001', volume: '10.0', member: alice) }

    before do
      subject.process({action: 'submit', order: existing.to_matching_attributes}, {}, {})
    end

    it "should cancel existing order" do
      subject.process({action: 'cancel', order: existing.to_matching_attributes}, {}, {})
      subject.engines[market.id].ask_orders.limit_orders.should be_empty
    end
  end

  context "dryrun" do
    let!(:ask) { create(:order_ask, price: '4000', volume: '3.0', member: alice) }
    let!(:bid) { create(:order_bid, price: '4001', volume: '8.0', member: bob) }

    subject { Worker::Matching.new(mode: :dryrun) }

    context "very old orders matched" do
      before do
        ask.update_column :created_at, 1.day.ago
      end

      it "should not start engine" do
        subject.engines['btccny'].mode.should == :dryrun
        subject.engines['btccny'].queue.should have(1).trade
      end
    end

    context "buffered orders matched" do
      it "should start engine" do
        subject.engines['btccny'].mode.should == :run
      end
    end
  end

end
