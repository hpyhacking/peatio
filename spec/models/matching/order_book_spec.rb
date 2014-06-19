require 'spec_helper'

describe Matching::OrderBook do

  context "#find" do
    subject { Matching::OrderBook.new('btccny', :ask) }

    it "should find specific order" do
      o1 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      o2 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      subject.add o1
      subject.add o2

      subject.find(o1.dup).object_id.should == o1.object_id
      subject.find(o2.dup).object_id.should == o2.object_id
    end
  end

  context "#add" do
    subject { Matching::OrderBook.new('btccny', :ask) }

    it "should reject invalid order whose volume is zero" do
      expect {
        subject.add Matching.mock_limit_order(type: :ask, volume: '0.0'.to_d)
      }.to raise_error(::Matching::InvalidOrderError)
    end

    it "should add market order" do
      subject.add Matching.mock_limit_order(type: :ask)

      o1 = Matching.mock_market_order(type: :ask)
      o2 = Matching.mock_market_order(type: :ask)
      o3 = Matching.mock_market_order(type: :ask)
      subject.add o1
      subject.add o2
      subject.add o3

      subject.market_orders.should == [o1, o2, o3]
    end

    it "should create price level for order with new price" do
      order = Matching.mock_limit_order(type: :ask)
      subject.add order
      subject.limit_orders.keys.first.should == order.price
      subject.limit_orders.values.first.should == [order]
    end

    it "should add order with same price to same price level" do
      o1 = Matching.mock_limit_order(type: :ask)
      o2 = Matching.mock_limit_order(type: :ask, price: o1.price)
      subject.add o1
      subject.add o2

      subject.limit_orders.keys.should have(1).price_level
      subject.limit_orders.values.first.should == [o1, o2]
    end

    it "should broadcast add event" do
      order = Matching.mock_limit_order(type: :ask)

      AMQPQueue.expects(:enqueue).with(:slave_book, {action: 'new', market: 'btccny', side: :ask}, {persistent: false})
      AMQPQueue.expects(:enqueue).with(:slave_book, {action: 'add', order: order.attributes}, {persistent: false})
      subject.add order
    end

    it "should not broadcast add event" do
      order = Matching.mock_limit_order(type: :ask)

      AMQPQueue.expects(:enqueue).with(:slave_book, {action: 'add', order: order.attributes}, {persistent: false}).never
      Matching::OrderBook.new('btccny', :ask, broadcast: false).add order
    end
  end

  context "#remove" do
    subject { Matching::OrderBook.new('btccny', :ask) }

    it "should remove market order" do
      subject.add Matching.mock_limit_order(type: :ask)
      order = Matching.mock_market_order(type: :ask)
      subject.add order
      subject.remove order
      subject.market_orders.should be_empty
    end

    it "should remove limit order" do
      o1 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      o2 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      subject.add o1
      subject.add o2
      subject.remove o1.dup # dup so it's not the same object, but has same id

      subject.limit_orders.values.first.should have(1).order
    end

    it "should remove price level if its only limit order removed" do
      order = Matching.mock_limit_order(type: :ask)
      subject.add order
      subject.remove order.dup
      subject.limit_orders.should be_empty
    end

    it "should return nil if order is not found" do
      order = Matching.mock_limit_order(type: :ask)
      subject.remove(order).should be_nil
    end

    it "should return order in book" do
      o1 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      o2 = o1.dup
      o1.volume = '12345'.to_d
      subject.add o1
      o = subject.remove o2
      o.volume.should == '12345'.to_d
    end
  end

  context "#best_limit_price" do
    it "should return highest bid price" do
      book = Matching::OrderBook.new('btccny', :bid)
      o1   = Matching.mock_limit_order(type: :bid, price: '1.0'.to_d)
      o2   = Matching.mock_limit_order(type: :bid, price: '2.0'.to_d)
      book.add o1
      book.add o2

      book.best_limit_price.should == o2.price
    end

    it "should return lowest ask price" do
      book = Matching::OrderBook.new('btccny', :ask)
      o1   = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      o2   = Matching.mock_limit_order(type: :ask, price: '2.0'.to_d)
      book.add o1
      book.add o2

      book.best_limit_price.should == o1.price
    end

    it "should return nil if there's no limit order" do
      book = Matching::OrderBook.new('btccny', :ask)
      book.best_limit_price.should be_nil
    end
  end

  context "#top" do
    it "should return market order if there's any market order" do
      book = Matching::OrderBook.new('btccny', :ask)
      o1 = Matching.mock_limit_order(type: :ask)
      o2 = Matching.mock_market_order(type: :ask)
      book.add o1
      book.add o2

      book.top.should == o2
    end

    it "should return nil for empty book" do
      book = Matching::OrderBook.new('btccny', :ask)
      book.top.should be_nil
    end

    it "should find ask order with lowest price" do
      book = Matching::OrderBook.new('btccny', :ask)
      o1 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      o2 = Matching.mock_limit_order(type: :ask, price: '2.0'.to_d)
      book.add o1
      book.add o2

      book.top.should == o1
    end

    it "should find bid order with highest price" do
      book = Matching::OrderBook.new('btccny', :bid)
      o1 = Matching.mock_limit_order(type: :bid, price: '1.0'.to_d)
      o2 = Matching.mock_limit_order(type: :bid, price: '2.0'.to_d)
      book.add o1
      book.add o2

      book.top.should == o2
    end

    it "should favor earlier order if orders have same price" do
      book = Matching::OrderBook.new('btccny', :ask)
      o1 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      o2 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      book.add o1
      book.add o2

      book.top.should == o1
    end
  end

  context "#fill_top" do
    subject { Matching::OrderBook.new('btccny', :ask) }

    it "should raise error if there is no top order" do
      expect { subject.fill_top '1.0'.to_d, '1.0'.to_d, '1.0'.to_d }.to raise_error
    end

    it "should complete fill the top market order" do
      subject.add Matching.mock_limit_order(type: :ask, volume: '1.0'.to_d)
      subject.add Matching.mock_market_order(type: :ask, volume: '1.0'.to_d)
      subject.fill_top '1.0'.to_d, '1.0'.to_d, '1.0'.to_d
      subject.market_orders.should be_empty
      subject.limit_orders.should have(1).order
    end

    it "should partial fill the top market order" do
      subject.add Matching.mock_limit_order(type: :ask, volume: '1.0'.to_d)
      subject.add Matching.mock_market_order(type: :ask, volume: '1.0'.to_d)
      subject.fill_top '1.0'.to_d, '0.6'.to_d, '0.6'.to_d
      subject.market_orders.first.volume.should == '0.4'.to_d
      subject.limit_orders.should have(1).order
    end

    it "should remove the price level if top order is the only order in level" do
      subject.add Matching.mock_limit_order(type: :ask, volume: '1.0'.to_d)
      subject.fill_top '1.0'.to_d, '1.0'.to_d, '1.0'.to_d
      subject.limit_orders.should be_empty
    end

    it "should remove order from level" do
      subject.add Matching.mock_limit_order(type: :ask, volume: '1.0'.to_d)
      subject.add Matching.mock_limit_order(type: :ask, volume: '1.0'.to_d)
      subject.fill_top '1.0'.to_d, '1.0'.to_d, '1.0'.to_d
      subject.limit_orders.values.first.should have(1).order
    end

    it "should fill top order with volume" do
      subject.add Matching.mock_limit_order(type: :ask, volume: '2.0'.to_d)
      subject.fill_top '1.0'.to_d, '0.5'.to_d, '0.5'.to_d
      subject.top.volume.should == '1.5'.to_d
    end
  end

end
