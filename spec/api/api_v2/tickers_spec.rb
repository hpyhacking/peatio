require 'spec_helper'

describe APIv2::Tickers do

  describe "GET /api/v2/tickers/:market" do

    it "should return market tickers" do
      get "/api/v2/tickers/btccny"
      response.should be_success
      JSON.parse(response.body)['ticker'].should == {"buy"=>"0.0", "sell"=>"0.0", "low"=>"0.0", "high"=>"0.0", "last"=>"0.0", "vol"=>"0.0"}
    end

  end

end
