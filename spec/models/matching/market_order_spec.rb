require 'spec_helper'

describe Matching::MarketOrder do

  context "initialize" do
    it "should not allow price attribute" do
      expect { Matching.mock_market_order(type: :ask, price: '1.0'.to_d) }.to raise_error
    end

    it "should have positive sum limit" do
      expect { Matching.mock_market_order(type: :ask, sum_limit: '0.0'.to_d) }.to raise_error
    end
  end

end
