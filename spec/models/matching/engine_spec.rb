require 'spec_helper'

describe Matching::Engine do

  let(:market) { Market.find('btccny') }
  let(:price)  { 10.to_d }
  let(:volume) { 5.to_d }
  let(:ask)    { Matching.mock_order(type: :ask, price: price, volume: volume)}
  let(:bid)    { Matching.mock_order(type: :bid, price: price, volume: volume)}

  subject { Matching::Engine.new(market) }

  context "submit full match orders" do
    it "should execute trade" do
      AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume}, anything)

      subject.submit(ask)
      subject.submit(bid)

      subject.ask_limit_orders.dump.should be_empty
      subject.bid_limit_orders.dump.should be_empty
    end
  end

  context "submit single partial match orders" do
    let(:ask) { Matching.mock_order(type: :ask, price: price, volume: 3.to_d)}

    it "should execute trade" do
      AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: 3.to_d}, anything)

      subject.submit(ask)
      subject.submit(bid)

      subject.ask_limit_orders.dump.should be_empty
      subject.bid_limit_orders.dump.should_not be_empty
    end
  end

  context "submit an order matching multiple orders" do
    let(:bid)    { Matching.mock_order(type: :bid, price: price, volume: 10.to_d)}

    let(:asks) do
      [nil,nil,nil].map do
        Matching.mock_order(type: :ask, price: price, volume: 3.to_d)
      end
    end

    it "should execute trade" do
      AMQPQueue.expects(:enqueue).times(asks.size)

      asks.each {|ask| subject.submit(ask) }
      subject.submit(bid)

      subject.ask_limit_orders.dump.should be_empty
      subject.bid_limit_orders.dump.should_not be_empty
    end
  end

  context "submit full match order after some cancellaton" do
    let(:bid)      { Matching.mock_order(type: :bid, price: price,   volume: 10.to_d)}
    let(:low_ask)  { Matching.mock_order(type: :ask, price: price-1, volume: 3.to_d) }
    let(:high_ask) { Matching.mock_order(type: :ask, price: price,   volume: 3.to_d) }

    it "should match bid with high ask" do
      subject.submit(low_ask) # low ask enters first
      subject.submit(high_ask)
      subject.cancel(low_ask) # but it's cancelled

      AMQPQueue.expects(:enqueue)
        .with(:trade_executor, {market_id: market.id, ask_id: high_ask.id, bid_id: bid.id, strike_price: high_ask.price, volume: high_ask.volume}, anything)
      subject.submit(bid)

      subject.ask_limit_orders.dump.should be_empty
      subject.bid_limit_orders.dump.should_not be_empty
    end
  end


end
