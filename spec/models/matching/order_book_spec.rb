require 'spec_helper'

describe Matching::OrderBook do

  subject { Matching::OrderBook.new(:ask) }

  context "add order" do
    it "should raise error given invalid ord_type" do
      order = Matching.mock_order(type: :ask, ord_type: 'test')
      expect { subject.add order }.to raise_error(ArgumentError)
    end

    it "should raise error given wrong order type" do
      order = Matching.mock_order(type: :bid)
      expect { subject.add order }.to raise_error(ArgumentError)
    end

    it "should create price level for order with new price" do
      order = Matching.mock_order(type: :ask)
      subject.add order
      subject.dump[:limit_orders].keys.first.should == order.price
      subject.dump[:limit_orders].values.first.should have(1).order
    end

    it "should add order with same price to same price level" do
      o1 = Matching.mock_order(type: :ask)
      o2 = Matching.mock_order(type: :ask, price: o1.price)
      subject.add o1
      subject.add o2

      subject.dump[:limit_orders].keys.should have(1).price_level
      subject.dump[:limit_orders].values.first.should have(2).orders
    end
  end

end
