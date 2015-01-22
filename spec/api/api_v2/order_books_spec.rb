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

  describe "GET /api/v2/depth" do
    let(:asks) { [['100', '2.0'], ['120', '1.0']] }
    let(:bids) { [['90', '3.0'], ['50', '1.0']] }

    before do
      global = mock("global", asks: asks, bids: bids)
      Global.stubs(:[]).returns(global)
    end

    it "should sort asks and bids from highest to lowest" do
      get '/api/v2/depth', market: 'btccny'
      response.should be_success

      result = JSON.parse(response.body)
      result['asks'].should == asks.reverse
      result['bids'].should == bids
    end
  end

end
