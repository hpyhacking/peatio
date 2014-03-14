require 'spec_helper'

describe Matching::FIFOEngine do

  let(:market) { Market.find('cnybtc') }
  let(:price)  { 10.to_d }
  let(:volume) { 5.to_d }
  let(:ask)    { Matching.mock_order(type: :ask, price: price, volume: volume)}
  let(:bid)    { Matching.mock_order(type: :bid, price: price, volume: volume)}

  subject { Matching::FIFOEngine.new(market) }

  context "#match?" do
    it "should not match given empty orderbook" do
      subject.should_not be_match
    end

    it "should not match given only one order" do
      ob = ::Matching::OrderBook.new
      ob.submit ask
      subject.stubs(:orderbook).returns(ob)

      subject.should_not be_match
    end

    it "should match given full match orders" do
      ob = ::Matching::OrderBook.new
      ob.submit ask
      ob.submit bid
      subject.stubs(:orderbook).returns(ob)

      subject.should be_match
    end
  end

  context "submit full match orders" do
    it "should execute trade" do
      executor = mock()
      executor.stubs(:execute!)

      ::Matching::Executor.expects(:new)
        .with(market, ask, bid, price, volume).returns(executor)

      subject.submit!(ask)
      subject.submit!(bid)
      subject.should_not be_match # after all matching done
    end
  end

  context "submit single partial match orders" do
    let(:ask) { Matching.mock_order(type: :ask, price: price, volume: 3.to_d)}

    it "should execute trade" do
      executor = mock()
      executor.stubs(:execute!)

      ::Matching::Executor.expects(:new)
        .with(market, ask, bid, price, 3.to_d).returns(executor)

      subject.submit!(ask)
      subject.submit!(bid)
      subject.should_not be_match # after all matching done
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
      executor = mock()
      executor.stubs(:execute!)

      asks.each do |ask|
        ::Matching::Executor.expects(:new).returns(executor).once
      end

      asks.each {|ask| subject.submit!(ask) }
      subject.submit!(bid)

      subject.should_not be_match # after all matching done
    end
  end

  context "submit full match order after some cancellaton" do
    let(:bid)      { Matching.mock_order(type: :bid, price: price,   volume: 10.to_d)}
    let(:low_ask)  { Matching.mock_order(type: :ask, price: price-1, volume: 3.to_d) }
    let(:high_ask) { Matching.mock_order(type: :ask, price: price,   volume: 3.to_d) }

    it "should match bid with high ask" do
      executor = mock()
      executor.stubs(:execute!)

      subject.submit!(low_ask) # low ask enters first
      subject.submit!(high_ask)
      subject.cancel!(low_ask) # but it's cancelled

      ::Matching::Executor.expects(:new).with(anything, high_ask, bid, anything, anything).returns(executor)
      subject.submit!(bid)
    end
  end


end
