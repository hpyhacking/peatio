require 'spec_helper'

describe Matching::Engine do

  let(:market) { Market.find('btccny') }
  let(:price)  { 10.to_d }
  let(:volume) { 5.to_d }
  let(:ask)    { Matching.mock_limit_order(type: :ask, price: price, volume: volume)}
  let(:bid)    { Matching.mock_limit_order(type: :bid, price: price, volume: volume)}

  subject { Matching::Engine.new(market) }

  context "submit market order" do
    let(:ask1) { Matching.mock_limit_order(type: :ask, price: '1.0'.to_d, volume: '1.0'.to_d) }
    let(:ask2) { Matching.mock_limit_order(type: :ask, price: '2.0'.to_d, volume: '1.0'.to_d) }
    let(:ask3) { Matching.mock_limit_order(type: :ask, price: '3.0'.to_d, volume: '1.0'.to_d) }

    it "should fill the market order completely" do
      mo   = Matching.mock_market_order(type: :bid, sum_limit: '6.0'.to_d, volume: '2.4'.to_d)

      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask1.id, bid_id: mo.id, strike_price: ask1.price, volume: ask1.volume}, anything)
      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask2.id, bid_id: mo.id, strike_price: ask2.price, volume: ask2.volume}, anything)
      AMQPQueue.expects(:enqueue).with(:trade_executor, {market_id: market.id, ask_id: ask3.id, bid_id: mo.id, strike_price: ask3.price, volume: '0.4'.to_d}, anything)

      subject.submit ask1
      subject.submit ask2
      subject.submit ask3
      subject.submit mo

      subject.ask_orders.limit_orders.should have(1).price_level
      subject.ask_orders.limit_orders.values.first.should == [ask3]
      ask3.volume.should == '0.6'.to_d

      subject.bid_orders.market_orders.should be_empty
    end
  end

  context "submit full match orders" do
    it "should execute trade" do
      AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume}, anything)

      subject.submit(ask)
      subject.submit(bid)

      subject.ask_orders.limit_orders.should be_empty
      subject.bid_orders.limit_orders.should be_empty
    end
  end

  context "submit single partial match orders" do
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

  context "submit an order matching multiple orders" do
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

  context "submit full match order after some cancellaton" do
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
