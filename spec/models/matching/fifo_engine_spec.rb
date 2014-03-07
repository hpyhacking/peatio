require 'spec_helper'

describe Matching::FIFOEngine do

  let(:market) { Market.find('cnybtc') }

  subject { Matching::FIFOEngine.new(market) }

  context "with empty orderbook" do
    it "should have no match" do
      subject.should_not be_match
    end
  end

  context "submit one order" do
    let(:order) { Matching.mock_order(type: :ask) }

    it "should have no match orders" do
      subject.submit(order)
      subject.should_not be_match
    end
  end

  context "submit full matching orders" do
    let(:price)  { 10.to_d }
    let(:volume) { 5.to_d }
    let(:ask)    { Matching.mock_order(type: :ask, price: price, volume: volume)}
    let(:bid)    { Matching.mock_order(type: :bid, price: price, volume: volume)}

    it "should find matching order" do
      subject.submit(ask)
      subject.submit(bid)
      subject.should be_match
    end

    it "should execute trade" do
      executor = mock()
      executor.stubs(:execute!).returns(Trade.new)

      ::Matching::Executor.expects(:new)
        .with(market, ask, bid, price, volume).returns(executor)

      subject.submit_and_run!(ask)
      subject.submit_and_run!(bid)
      subject.should_not be_match # after all matching done
    end
  end

end
