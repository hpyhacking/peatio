require 'spec_helper'

describe Matching::OrderBook do

  subject { Matching::OrderBook.new }

  context "Empty" do
    its(:matchable?) { should be_false }
  end

  context "Filled" do
    before do
      5.times do |i|
        subject.submit Matching.mock_order(type: :ask, price: 1+i)
        subject.submit Matching.mock_order(type: :bid, price: 1+i)
      end
    end

    its(:matchable?) { should be_true }

    it "should cancel order" do
      subject.cancel subject.lowest_ask
      subject.lowest_ask.price.should == 2.to_d
    end

    it "should return order ask for lowest price" do
      subject.lowest_ask.price.should == 1.to_d
    end

    it "should return order bid with highest price" do
      subject.highest_bid.price.should == 5.to_d
    end

    it "should insert new lowest ask order" do
      subject.submit Matching.mock_order(type: :ask, price: 0.5)
      subject.lowest_ask.price.should == 0.5.to_d
    end

    it "should insert new highest bid order" do
      subject.submit Matching.mock_order(type: :bid, price: 100)
      subject.highest_bid.price.should == 100.to_d
    end

    it "should delete lowest ask order" do
      subject.delete_ask subject.lowest_ask
      subject.lowest_ask.price.should == 2.to_d
    end

    it "should delete highest bid order" do
      subject.delete_bid subject.highest_bid
      subject.highest_bid.price.should == 4.to_d
    end

    it "should pop the ask and bid with closest prices" do
      ask, bid = subject.pop_closest_pair!

      ask.price.should == 1.to_d
      bid.price.should == 5.to_d

      subject.lowest_ask.price.should == 2.to_d
      subject.highest_bid.price.should == 4.to_d
    end

  end

  context "#depth" do
    before do
      5.times do |i|
        subject.submit Matching.mock_order(type: :ask, price: 1+i, volume: rand(5)+1)
        subject.submit Matching.mock_order(type: :bid, price: 1+i, volume: rand(5)+1)
      end
    end

    it "should return asks and bids" do
      subject.depth[:asks].first.should match(/^\$1\.0/)
      subject.depth[:bids].first.should match(/^\$1\.0/)
    end
  end

end
