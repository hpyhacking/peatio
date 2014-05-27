require 'spec_helper'

describe Matching::LimitOrderBook do

  context "#add" do
    subject { Matching::LimitOrderBook.new(:ask) }

    it "should create price level for order with new price" do
      order = Matching.mock_order(type: :ask)
      subject.add order
      subject.dump.keys.first.should == order.price
      subject.dump.values.first.should have(1).order
    end

    it "should add order with same price to same price level" do
      o1 = Matching.mock_order(type: :ask)
      o2 = Matching.mock_order(type: :ask, price: o1.price)
      subject.add o1
      subject.add o2

      subject.dump.keys.should have(1).price_level
      subject.dump.values.first.should have(2).orders
    end
  end

  context "#remove" do
    subject { Matching::LimitOrderBook.new(:ask) }

    it "should remove order" do
      order = Matching.mock_order(type: :ask)
      subject.add order
      subject.remove order
      subject.dump.values.first.should be_empty
    end
  end

  context "#top" do
    it "should return nil for empty book" do
      book = Matching::LimitOrderBook.new(:ask)
      book.top.should be_nil
    end

    it "should find ask order with lowest price" do
      book = Matching::LimitOrderBook.new(:ask)
      o1 = Matching.mock_order(type: :ask, price: '1.0'.to_d)
      o2 = Matching.mock_order(type: :ask, price: '2.0'.to_d)
      book.add o1
      book.add o2

      book.top.should == o1
    end

    it "should find bid order with highest price" do
      book = Matching::LimitOrderBook.new(:bid)
      o1 = Matching.mock_order(type: :bid, price: '1.0'.to_d)
      o2 = Matching.mock_order(type: :bid, price: '2.0'.to_d)
      book.add o1
      book.add o2

      book.top.should == o2
    end

    it "should favor earlier order if orders have same price" do
      book = Matching::LimitOrderBook.new(:ask)
      o1 = Matching.mock_order(type: :ask, price: '1.0'.to_d)
      o2 = Matching.mock_order(type: :ask, price: '1.0'.to_d)
      book.add o1
      book.add o2

      book.top.should == o1
    end
  end
end
