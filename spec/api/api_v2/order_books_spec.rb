require 'spec_helper'

describe APIv2::OrderBooks do

  describe "GET /api/v2/order_book" do
    before do
      5.times { create(:order_bid) }
      5.times { create(:order_ask) }
    end

    it "should return ask and bid orders on specified market" do
      get '/api/v2/order_book', market: 'btccny'
      response.should be_success

      result = JSON.parse(response.body)
      result['asks'].should have(5).asks
      result['bids'].should have(5).bids
    end

    it "should return limited asks and bids" do
      get '/api/v2/order_book', market: 'btccny', asks_limit: 1, bids_limit: 1
      response.should be_success

      result = JSON.parse(response.body)
      result['asks'].should have(1).asks
      result['bids'].should have(1).bids
    end
  end

end
