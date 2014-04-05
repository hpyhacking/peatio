require 'spec_helper'

describe Matching::Executor do

  let(:alice)  { who_is_billionaire(:alice) }
  let(:bob)    { who_is_billionaire(:bob) }
  let(:market) { Market.find('btccny') }
  let(:price)  { 10.to_d }
  let(:volume) { 5.to_d }

  subject { Matching::Executor.new(market, ask, bid, price, volume) }

  context "invalid volume" do
    let(:ask) { ::Matching::Order.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::Order.new create(:order_bid, price: price, volume: 3.to_d, member: bob).to_matching_attributes }

    it "should raise error" do
      expect { subject.execute! }.to raise_error(Matching::TradeExecutionError)
    end
  end

  context "invalid price" do
    let(:ask) { ::Matching::Order.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::Order.new create(:order_bid, price: price-1, volume: volume, member: bob).to_matching_attributes }

    it "should raise error" do
      expect { subject.execute! }.to raise_error(Matching::TradeExecutionError)
    end
  end

  context "full execution" do
    let(:ask) { ::Matching::Order.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::Order.new create(:order_bid, price: price, volume: volume, member: bob).to_matching_attributes }

    it "should create trade" do
      expect {
        trade = subject.execute!

        trade.trend.should  == 'up'
        trade.price.should  == price
        trade.volume.should == volume
        trade.ask_id.should == ask.id
        trade.bid_id.should == bid.id
      }.to change(Trade, :count).by(1)
    end

    it "should set trend to down" do
      market.expects(:latest_price).returns(11.to_d)
      trade = subject.execute!

      trade.trend.should == 'down'
    end

    it "should mark both orders as done" do
      subject.execute!

      Order.find(ask.id).state.should == Order::DONE
      Order.find(bid.id).state.should == Order::DONE
    end

    it "should publish trade through pusher" do
      Pusher.expects(:trigger_async)
      subject.execute!
    end
  end

  context "partial ask execution" do
    let(:ask) { create(:order_ask, price: price, volume: 7.to_d, member: alice) }
    let(:bid) { create(:order_bid, price: price, volume: 5.to_d, member: bob) }

    it "should set bid to done only" do
      subject.execute!

      ask.reload.state.should_not == Order::DONE
      bid.reload.state.should == Order::DONE
    end
  end

  context "partial bid execution" do
    let(:ask) { create(:order_ask, price: price, volume: 5.to_d, member: alice) }
    let(:bid) { create(:order_bid, price: price, volume: 7.to_d, member: bob) }

    it "should set ask to done only" do
      subject.execute!

      ask.reload.state.should == Order::DONE
      bid.reload.state.should_not == Order::DONE
    end
  end

end
