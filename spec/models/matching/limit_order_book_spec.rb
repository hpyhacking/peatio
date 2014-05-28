require 'spec_helper'

describe Matching::LimitOrderBook do

  context "#add" do
    subject { Matching::LimitOrderBook.new(:ask) }

    it "should create price level for order with new price" do
      order = Matching.mock_limit_order(type: :ask)
      subject.add order
      subject.dump.keys.first.should == order.price
      subject.dump.values.first.should have(1).order
    end

    it "should add order with same price to same price level" do
      o1 = Matching.mock_limit_order(type: :ask)
      o2 = Matching.mock_limit_order(type: :ask, price: o1.price)
      subject.add o1
      subject.add o2

      subject.dump.keys.should have(1).price_level
      subject.dump.values.first.should have(2).orders
    end
  end

  context "#remove" do
    subject { Matching::LimitOrderBook.new(:ask) }

    it "should remove order" do
      o1 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      o2 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      subject.add o1
      subject.add o2
      subject.remove o1.dup # dup so it's not the same object, but has same id

      subject.dump.values.first.should have(1).order
    end

    it "should remove price level if its only order removed" do
      order = Matching.mock_limit_order(type: :ask)
      subject.add order
      subject.remove order.dup
      subject.dump.should be_empty
    end
  end

  context "#top" do
    it "should return nil for empty book" do
      book = Matching::LimitOrderBook.new(:ask)
      book.top.should be_nil
    end

    it "should find ask order with lowest price" do
      book = Matching::LimitOrderBook.new(:ask)
      o1 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      o2 = Matching.mock_limit_order(type: :ask, price: '2.0'.to_d)
      book.add o1
      book.add o2

      book.top.should == o1
    end

    it "should find bid order with highest price" do
      book = Matching::LimitOrderBook.new(:bid)
      o1 = Matching.mock_limit_order(type: :bid, price: '1.0'.to_d)
      o2 = Matching.mock_limit_order(type: :bid, price: '2.0'.to_d)
      book.add o1
      book.add o2

      book.top.should == o2
    end

    it "should favor earlier order if orders have same price" do
      book = Matching::LimitOrderBook.new(:ask)
      o1 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      o2 = Matching.mock_limit_order(type: :ask, price: '1.0'.to_d)
      book.add o1
      book.add o2

      book.top.should == o1
    end
  end

  context "#fill_top" do
    subject { Matching::LimitOrderBook.new(:ask) }

    it "should raise error if there is no top order" do
      expect { subject.fill_top '1.0'.to_d }.to raise_error
    end

    it "should remove the price level if top order is the only order in level" do
      subject.add Matching.mock_limit_order(type: :ask, volume: '1.0'.to_d)
      subject.fill_top '1.0'.to_d
      subject.dump.should be_empty
    end

    it "should remove order from level" do
      subject.add Matching.mock_limit_order(type: :ask, volume: '1.0'.to_d)
      subject.add Matching.mock_limit_order(type: :ask, volume: '1.0'.to_d)
      subject.fill_top '1.0'.to_d
      subject.dump.values.first.should have(1).order
    end

    it "should fill top order with volume" do
      subject.add Matching.mock_limit_order(type: :ask, volume: '2.0'.to_d)
      subject.fill_top '0.5'.to_d
      subject.top.volume.should == '1.5'.to_d
    end
  end

end
