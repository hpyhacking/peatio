require 'spec_helper'

describe Matching::Engine do

  let(:market) { Market.find('btccny') }
  let(:price)  { 10.to_d }
  let(:volume) { 5.to_d }
  let(:ask)    { Matching.mock_limit_order(type: :ask, price: price, volume: volume)}
  let(:bid)    { Matching.mock_limit_order(type: :bid, price: price, volume: volume)}

  subject { Matching::Engine.new(market) }

  context "submit market order" do
    let(:bid)  { Matching.mock_limit_order(type: :bid, price: '0.1'.to_d, volume: '0.1'.to_d) }
    let(:ask1) { Matching.mock_limit_order(type: :ask, price: '1.0'.to_d, volume: '1.0'.to_d) }
    let(:ask2) { Matching.mock_limit_order(type: :ask, price: '2.0'.to_d, volume: '1.0'.to_d) }
    let(:ask3) { Matching.mock_limit_order(type: :ask, price: '3.0'.to_d, volume: '1.0'.to_d) }

    it "should fill the market order completely" do
      mo = Matching.mock_market_order(type: :bid, sum_limit: '6.0'.to_d, volume: '2.4'.to_d)

      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask1.id, bid_id: mo.id, strike_price: ask1.price, volume: ask1.volume}, anything)
      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask2.id, bid_id: mo.id, strike_price: ask2.price, volume: ask2.volume}, anything)
      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask3.id, bid_id: mo.id, strike_price: ask3.price, volume: '0.4'.to_d}, anything)

      subject.submit bid
      subject.submit ask1
      subject.submit ask2
      subject.submit ask3
      subject.submit mo

      subject.ask_orders.limit_orders.should have(1).price_level
      subject.ask_orders.limit_orders.values.first.should == [ask3]
      ask3.volume.should == '0.6'.to_d

      subject.bid_orders.market_orders.should be_empty
    end

    it "should fill the market order partially and put it in queue" do
      mo = Matching.mock_market_order(type: :bid, sum_limit: '6.0'.to_d, volume: '2.4'.to_d)

      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask1.id, bid_id: mo.id, strike_price: ask1.price, volume: ask1.volume}, anything)
      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask2.id, bid_id: mo.id, strike_price: ask2.price, volume: ask2.volume}, anything)

      subject.submit bid
      subject.submit ask1
      subject.submit ask2
      subject.submit mo

      subject.ask_orders.limit_orders.should be_empty
      subject.bid_orders.market_orders.should == [mo]
    end

    it "should match existing market order with best limit price" do
      mo1 = Matching.mock_market_order(type: :ask, sum_limit: '6.0'.to_d, volume: '1.4'.to_d)
      mo2 = Matching.mock_market_order(type: :bid, sum_limit: '6.0'.to_d, volume: '3.0'.to_d)

      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: mo1.id, bid_id: mo2.id, strike_price: ask1.price, volume: mo1.volume}, anything)
      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask1.id, bid_id: mo2.id, strike_price: ask1.price, volume: ask1.volume}, anything)

      subject.submit ask1
      subject.submit mo1
      subject.submit mo2

      subject.ask_orders.limit_orders.should be_empty
      subject.ask_orders.market_orders.should be_empty

      # there's no limit order in bid orderbook, so the partially matched
      # market order will be canceled
      subject.bid_orders.market_orders.should be_empty
    end

    it "should partially match existing market order" do
      mo1 = Matching.mock_market_order(type: :ask, sum_limit: '6.0'.to_d, volume: '1.4'.to_d)
      mo2 = Matching.mock_market_order(type: :bid, sum_limit: '6.0'.to_d, volume: '1.0'.to_d)

      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: mo1.id, bid_id: mo2.id, strike_price: ask1.price, volume: mo2.volume}, anything)

      subject.submit ask1
      subject.submit mo1
      subject.submit mo2

      subject.ask_orders.limit_orders.should_not be_empty
      subject.ask_orders.market_orders.should == [mo1]
      subject.bid_orders.market_orders.should be_empty

      mo1.volume.should == '0.4'.to_d
    end

    it "should cancel the market order if it's the first order in book" do
      mo1 = Matching.mock_market_order(type: :ask, sum_limit: '6.0'.to_d, volume: '1.4'.to_d)

      subject.expects(:publish_cancel).with(mo1, "market order protection")
      subject.submit mo1
    end

    it "should partially fill then cancel the market order if sum limit reached" do
      mo = Matching.mock_market_order(type: :bid, sum_limit: '2.5'.to_d, volume: '2'.to_d)

      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask1.id, bid_id: mo.id, strike_price: ask1.price, volume: ask1.volume}, anything)
      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask2.id, bid_id: mo.id, strike_price: ask2.price, volume: '0.75'.to_d}, anything)

      subject.submit bid
      subject.submit ask1
      subject.submit ask2
      subject.submit ask3
      subject.submit mo

      subject.ask_orders.limit_orders.should have(2).price_level
      ask2.volume.should == '0.25'.to_d
      ask3.volume.should == '1.0'.to_d

      subject.bid_orders.market_orders.should be_empty
    end
  end

  context "submit limit order" do
    it "should match existing market order" do
      bid = Matching.mock_limit_order(type: :bid, price: '0.1'.to_d, volume: '0.1'.to_d)
      mo = Matching.mock_market_order(type: :bid, sum_limit: '100.0'.to_d, volume: '6.0'.to_d)
      subject.submit bid
      subject.submit mo

      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask.id, bid_id: mo.id, strike_price: ask.price, volume: ask.volume}, anything)
      subject.submit ask

      subject.ask_orders.limit_orders.should be_empty
      subject.bid_orders.market_orders.should == [mo]
      mo.volume.should == '1.0'.to_d
    end

    context "fully match incoming order" do
      it "should execute trade" do
        AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume}, anything)

        subject.submit(ask)
        subject.submit(bid)

        subject.ask_orders.limit_orders.should be_empty
        subject.bid_orders.limit_orders.should be_empty
      end
    end

    context "partial match incoming order" do
      let(:ask) { Matching.mock_limit_order(type: :ask, price: price, volume: 3.to_d)}

      it "should execute trade" do
        AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: 3.to_d}, anything)

        subject.submit(ask)
        subject.submit(bid)

        subject.ask_orders.limit_orders.should be_empty
        subject.bid_orders.limit_orders.should_not be_empty

        subject.cancel(bid)
        subject.bid_orders.limit_orders.should be_empty
      end
    end

    context "match order with many counter orders" do
      let(:bid)    { Matching.mock_limit_order(type: :bid, price: price, volume: 10.to_d)}

      let(:asks) do
        [nil,nil,nil].map do
          Matching.mock_limit_order(type: :ask, price: price, volume: 3.to_d)
        end
      end

      it "should execute trade" do
        AMQPQueue.expects(:enqueue).times(asks.size)

        asks.each {|ask| subject.submit(ask) }
        subject.submit(bid)

        subject.ask_orders.limit_orders.should be_empty
        subject.bid_orders.limit_orders.should_not be_empty
      end
    end

    context "fully match order after some cancellatons" do
      let(:bid)      { Matching.mock_limit_order(type: :bid, price: price,   volume: 10.to_d)}
      let(:low_ask)  { Matching.mock_limit_order(type: :ask, price: price-1, volume: 3.to_d) }
      let(:high_ask) { Matching.mock_limit_order(type: :ask, price: price,   volume: 3.to_d) }

      it "should match bid with high ask" do
        subject.submit(low_ask) # low ask enters first
        subject.submit(high_ask)
        subject.cancel(low_ask) # but it's cancelled

        AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: high_ask.id, bid_id: bid.id, strike_price: high_ask.price, volume: high_ask.volume}, anything)
        subject.submit(bid)

        subject.ask_orders.limit_orders.should be_empty
        subject.bid_orders.limit_orders.should_not be_empty
      end
    end
  end

  context "#cancel" do
    it "should cancel order" do
      subject.submit(ask)
      subject.cancel(ask)
      subject.ask_orders.limit_orders.should be_empty

      subject.submit(bid)
      subject.cancel(bid)
      subject.bid_orders.limit_orders.should be_empty
    end
  end

end
