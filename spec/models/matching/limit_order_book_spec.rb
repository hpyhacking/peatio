require 'spec_helper'

describe Matching::LimitOrderBook do

  subject { Matching::LimitOrderBook.new(:ask) }

  context "add limit order" do
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

  context "remove limit order" do
    it "should remove order" do
      order = Matching.mock_order(type: :ask)
      subject.add order
      subject.remove order
      subject.dump.values.first.should be_empty
    end
  end

end
