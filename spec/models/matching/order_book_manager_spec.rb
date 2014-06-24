require 'spec_helper'

describe Matching::OrderBookManager do

  context ".build_order" do
    it "should build limit order" do
      order = ::Matching::OrderBookManager.build_order id: 1, market: 'btccny', ord_type: 'limit', type: 'ask', price: '1.0', volume: '1.0', timestamp: 12345
      order.should be_instance_of(::Matching::LimitOrder)
    end
  end

end
