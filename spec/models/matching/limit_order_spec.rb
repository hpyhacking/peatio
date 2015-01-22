require 'spec_helper'

describe Matching::LimitOrder do

  context "initialize" do
    it "should throw invalid order error for empty attributes" do
      expect {
        Matching::LimitOrder.new({type: '', price: '', volume: ''})
      }.to raise_error(Matching::InvalidOrderError)
    end

    it "should initialize market" do
        Matching.mock_limit_order(type: :bid).market.should be_instance_of(Market)
    end
  end

  context "crossed?" do
    it "should cross at lower or equal price for bid order" do
      order = Matching.mock_limit_order(type: :bid, price: '10.0'.to_d)
      order.crossed?('9.0'.to_d).should be_true
      order.crossed?('10.0'.to_d).should be_true
      order.crossed?('11.0'.to_d).should be_false
    end

    it "should cross at higher or equal price for ask order" do
      order = Matching.mock_limit_order(type: :ask, price: '10.0'.to_d)
      order.crossed?('9.0'.to_d).should be_false
      order.crossed?('10.0'.to_d).should be_true
      order.crossed?('11.0'.to_d).should be_true
    end
  end
end
