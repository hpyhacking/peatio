require 'spec_helper'

describe Order, 'validations' do
  it { should validate_presence_of(:ord_type) }
  it { should validate_presence_of(:volume) }
  it { should validate_presence_of(:origin_volume) }
  it { should validate_presence_of(:locked) }
  it { should validate_presence_of(:origin_locked) }

  context "limit order" do
    it "should make sure price is present" do
      order = Order.new(currency: 'btccny', price: nil, ord_type: 'limit')
      order.should_not be_valid
      order.errors[:price].should == ["is not a number"]
    end

    it "should make sure price is greater than zero" do
      order = Order.new(currency: 'btccny', price: '0.0'.to_d, ord_type: 'limit')
      order.should_not be_valid
      order.errors[:price].should == ["must be greater than 0"]
    end
  end

  context "market order" do
    it "should make sure price is not present" do
      order = Order.new(currency: 'btccny', price: '0.0'.to_d, ord_type: 'market')
      order.should_not be_valid
      order.errors[:price].should == ['must not be present']
    end
  end
end

describe Order, "#fix_number_precision" do
  let(:order_bid) { create(:order_bid, currency: 'btccny', price: '12.326'.to_d, volume: '123.123456789') }
  let(:order_ask) { create(:order_ask, currency: 'btccny', price: '12.326'.to_d, volume: '123.123456789') }
  it { expect(order_bid.price).to be_d '12.32' }
  it { expect(order_bid.volume).to be_d '123.1234' }
  it { expect(order_bid.origin_volume).to be_d '123.1234' }
  it { expect(order_ask.price).to be_d '12.32' }
  it { expect(order_ask.volume).to be_d '123.1234' }
  it { expect(order_ask.origin_volume).to be_d '123.1234' }
end

describe Order, "#done" do
  let(:ask_fee) { '0.003'.to_d }
  let(:bid_fee) { '0.001'.to_d }
  let(:order) { order_bid }
  let(:order_bid) { create(:order_bid, price: "1.2".to_d, volume: "10.0".to_d) }
  let(:order_ask) { create(:order_ask, price: "1.2".to_d, volume: "10.0".to_d) }
  let(:hold_account) { create(:account, member_id: 1, locked: "100.0".to_d, balance: "0.0".to_d) }
  let(:expect_account) { create(:account, member_id: 2, locked: "0.0".to_d, balance: "0.0".to_d) }

  before do
    order_bid.stubs(:hold_account).returns(hold_account)
    order_bid.stubs(:expect_account).returns(expect_account)
    order_ask.stubs(:hold_account).returns(hold_account)
    order_ask.stubs(:expect_account).returns(expect_account)
    OrderBid.any_instance.stubs(:fee).returns(bid_fee)
    OrderAsk.any_instance.stubs(:fee).returns(ask_fee)
  end

  def mock_trade(volume, price)
    build(:trade, volume: volume, price: price, id: rand(10))
  end

  shared_examples "trade done" do
    before do
      hold_account.reload
      expect_account.reload
    end

    it "order_bid done" do
      trade = mock_trade(strike_volume, strike_price)

      hold_account.expects(:unlock_and_sub_funds).with(
        strike_volume * strike_price, locked: strike_volume * strike_price,
        reason: Account::STRIKE_SUB, ref: trade)

      expect_account.expects(:plus_funds).with(
        strike_volume - strike_volume * bid_fee,
        has_entries(:reason => Account::STRIKE_ADD, :ref => trade))

      order_bid.strike(trade)
    end

    it "order_ask done" do
      trade = mock_trade(strike_volume, strike_price)
      hold_account.expects(:unlock_and_sub_funds).with(
        strike_volume, locked: strike_volume,
        reason: Account::STRIKE_SUB, ref: trade)

      expect_account.expects(:plus_funds).with(
        strike_volume * strike_price - strike_volume * strike_price * ask_fee,
        has_entries(:reason => Account::STRIKE_ADD, :ref => trade))

      order_ask.strike(trade)
    end
  end

  describe Order do
    describe "#state" do
      it "should be keep wait state" do
        expect do
          order.strike(mock_trade("5.0", "0.8"))
        end.to_not change{ order.state }.by(Order::WAIT)
      end

      it "should be change to done state" do
        expect do
          order.strike(mock_trade("10.0", "1.2"))
        end.to change{ order.state }.from(Order::WAIT).to(Order::DONE)
      end
    end

    describe "#volume" do
      it "should be change volume" do
        expect do
          order.strike(mock_trade("4.0", "1.2"))
        end.to change{ order.volume }.from("10.0".to_d).to("6.0".to_d)
      end

      it "should be don't change origin volume" do
        expect do
          order.strike(mock_trade("4.0", "1.2"))
        end.to_not change{ order.origin_volume }.by("10.0".to_d)
      end
    end

    describe "#trades_count" do
      it "should increase trades count" do
        expect do
          order.strike(mock_trade("4.0", "1.2"))
        end.to change{ order.trades_count }.from(0).to(1)
      end
    end

    describe "#done" do
      context "trade done volume 5.0 with price 0.8" do
        let(:strike_price) { "0.8".to_d }
        let(:strike_volume) { "5.0".to_d }
        it_behaves_like "trade done"
      end

      context "trade done volume 3.1 with price 0.7" do
        let(:strike_price) { "0.7".to_d }
        let(:strike_volume) { "3.1".to_d }
        it_behaves_like "trade done"
      end

      context "trade done volume 10.0 with price 0.8" do
        let(:strike_price)  { "0.8".to_d }
        let(:strike_volume) { "10.0".to_d }

        it "should unlock not used funds" do
          trade = mock_trade(strike_volume, strike_price)

          hold_account.expects(:unlock_and_sub_funds).with(
            strike_volume * strike_price, locked: strike_volume * strike_price,
            reason: Account::STRIKE_SUB, ref: trade)

          expect_account.expects(:plus_funds).with(
            strike_volume - strike_volume * bid_fee,
            has_entries(:reason => Account::STRIKE_ADD, :ref => trade))

          hold_account.expects(:unlock_funds).with(
            strike_volume * (order.price - strike_price),
            reason: Account::ORDER_FULLFILLED, ref: trade)

          order_bid.strike(trade)
        end
      end
    end
  end
end

describe Order, "#head" do
  let(:currency) { :btccny }

  describe OrderAsk do
    it "price priority" do
      foo = create(:order_ask, price: "1.0".to_d, created_at: 2.second.ago)
      create(:order_ask, price: "1.1".to_d, created_at: 1.second.ago)
      expect(OrderAsk.head(currency)).to eql foo
    end

    it "time priority" do
      foo = create(:order_ask, price: "1.0".to_d, created_at: 2.second.ago)
      create(:order_ask, price: "1.0".to_d, created_at: 1.second.ago)
      expect(OrderAsk.head(currency)).to eql foo
    end
  end

  describe OrderBid do
    it "price priority" do
      foo = create(:order_bid, price: "1.1".to_d, created_at: 2.second.ago)
      create(:order_bid, price: "1.0".to_d, created_at: 1.second.ago)
      expect(OrderBid.head(currency)).to eql foo
    end

    it "time priority" do
      foo = create(:order_bid, price: "1.0".to_d, created_at: 2.second.ago)
      create(:order_bid, price: "1.0".to_d, created_at: 1.second.ago)
      expect(OrderBid.head(currency)).to eql foo
    end
  end
end

describe Order, "#kind" do
  it "should be ask for ask order" do
    OrderAsk.new.kind.should == 'ask'
  end

  it "should be bid for bid order" do
    OrderBid.new.kind.should == 'bid'
  end
end

describe Order, "related accounts" do
  let(:alice)  { who_is_billionaire }
  let(:bob)    { who_is_billionaire }

  context OrderAsk do
    it "should hold btc and expect cny" do
      ask = create(:order_ask, member: alice)
      ask.hold_account.should == alice.get_account(:btc)
      ask.expect_account.should == alice.get_account(:cny)
    end
  end

  context OrderBid do
    it "should hold cny and expect btc" do
      bid = create(:order_bid, member: bob)
      bid.hold_account.should == bob.get_account(:cny)
      bid.expect_account.should == bob.get_account(:btc)
    end
  end
end

describe Order, "#avg_price" do
  it "should be zero if not filled yet" do
    OrderAsk.new(locked: '1.0', origin_locked: '1.0', volume: '1.0', origin_volume: '1.0', funds_received: '0').avg_price.should == '0'.to_d
    OrderBid.new(locked: '1.0', origin_locked: '1.0', volume: '1.0', origin_volume: '1.0', funds_received: '0').avg_price.should == '0'.to_d
  end

  it "should calculate average price of bid order" do
    OrderBid.new(currency: 'btccny', locked: '10.0', origin_locked: '20.0', volume: '1.0', origin_volume: '3.0', funds_received: '2.0').avg_price.should == '5'.to_d
  end

  it "should calculate average price of ask order" do
    OrderAsk.new(currency: 'btccny', locked: '1.0', origin_locked: '2.0', volume: '1.0', origin_volume: '2.0', funds_received: '10.0').avg_price.should == '10'.to_d
  end
end

describe Order, "#estimate_required_funds" do
  let(:price_levels) do
    [ ['1.0'.to_d, '10.0'.to_d],
      ['2.0'.to_d, '20.0'.to_d],
      ['3.0'.to_d, '30.0'.to_d] ]
  end

  before do
    global = Global.new('btccny')
    global.stubs(:asks).returns(price_levels)
    Global.stubs(:[]).returns(global)
  end
end

describe Order, "#strike" do
  it "should raise error if order has been cancelled" do
    order = Order.new(state: Order::CANCEL)
    expect { order.strike(mock('trade')) }.to raise_error
  end
end
