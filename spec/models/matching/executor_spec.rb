require 'spec_helper'

describe Matching::Executor do

  let(:alice)  { who_is_billionaire }
  let(:bob)    { who_is_billionaire }
  let(:market) { Market.find('btccny') }
  let(:price)  { 10.to_d }
  let(:volume) { 5.to_d }

  subject {
    Matching::Executor.new(
      market_id:    market.id,
      ask_id:       ask.id,
      bid_id:       bid.id,
      strike_price: price.to_s('F'),
      volume:       volume.to_s('F'),
      funds:        (price*volume).to_s('F')
    )
  }

  context "invalid volume" do
    let(:ask) { ::Matching::LimitOrder.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::LimitOrder.new create(:order_bid, price: price, volume: 3.to_d, member: bob).to_matching_attributes }

    it "should raise error" do
      expect { subject.execute! }.to raise_error(Matching::TradeExecutionError)
    end
  end

  context "invalid price" do
    let(:ask) { ::Matching::LimitOrder.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::LimitOrder.new create(:order_bid, price: price-1, volume: volume, member: bob).to_matching_attributes }

    it "should raise error" do
      expect { subject.execute! }.to raise_error(Matching::TradeExecutionError)
    end
  end

  context "full execution" do
    let(:ask) { ::Matching::LimitOrder.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::LimitOrder.new create(:order_bid, price: price, volume: volume, member: bob).to_matching_attributes }

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

    it "should set trade used funds" do
      market.expects(:latest_price).returns(11.to_d)
      trade = subject.execute!
      trade.funds.should == price*volume
    end

    it "should increase order's trades count" do
      subject.execute!
      Order.find(ask.id).trades_count.should == 1
      Order.find(bid.id).trades_count.should == 1
    end

    it "should mark both orders as done" do
      subject.execute!

      Order.find(ask.id).state.should == Order::DONE
      Order.find(bid.id).state.should == Order::DONE
    end

    it "should publish trade through amqp" do
      AMQPQueue.expects(:publish)
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

  context "partially filled market order whose locked fund run out" do
    let(:ask) { create(:order_ask, price: '2.0'.to_d, volume: '3.0'.to_d, member: alice) }
    let(:bid) { create(:order_bid, price: nil, ord_type: 'market', volume: '2.0'.to_d, locked: '3.0'.to_d, member: bob) }

    it "should cancel the market order" do
      executor = Matching::Executor.new(
        market_id:    market.id,
        ask_id:       ask.id,
        bid_id:       bid.id,
        strike_price: '2.0',
        volume:       '1.5',
        funds:        '3.0'
      )
      executor.execute!

      bid.reload.state.should == Order::CANCEL
    end
  end

  context "unlock not used funds" do
    let(:ask) { create(:order_ask, price: price-1, volume: 7.to_d, member: alice) }
    let(:bid) { create(:order_bid, price: price, volume: volume, member: bob) }

    subject {
      Matching::Executor.new(
        market_id:    market.id,
        ask_id:       ask.id,
        bid_id:       bid.id,
        strike_price: price-1, # so bid order only used (price-1)*volume
        volume:       volume.to_s('F'),
        funds:        ((price-1)*volume).to_s('F')
      )
    }

    it "should unlock funds not used by bid order" do
      locked_before = bid.hold_account.reload.locked

      subject.execute!
      locked_after = bid.hold_account.reload.locked

      locked_after.should == locked_before - (price*volume)
    end

    it "should save unused amount in order locked attribute" do
      subject.execute!
      bid.reload.locked.should == price*volume - (price-1)*volume
    end
  end

  context "execution fail" do
    let(:ask) { ::Matching::LimitOrder.new create(:order_ask, price: price, volume: volume, member: alice).to_matching_attributes }
    let(:bid) { ::Matching::LimitOrder.new create(:order_bid, price: price, volume: volume, member: bob).to_matching_attributes }

    it "should not create trade" do
      # set locked funds to 0 so strike will fail
      alice.get_account(:btc).update_attributes(locked: ::Trade::ZERO)

      expect do
        expect { subject.execute! }.to raise_error(Account::LockedError)
      end.not_to change(Trade, :count)
    end
  end

end
