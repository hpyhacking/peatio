require 'spec_helper'

describe APIv2::Orders do

  describe "GET /api/v2/orders" do

    let(:member) { create(:member) }
    let(:token)  { create(:api_token, member: member) }

    before do
      create(:order_bid, currency: 'cnybtc', price: '12.326'.to_d, volume: '123.123456789', member: member)
      create(:order_ask, currency: 'cnybtc', price: '12.326'.to_d, volume: '123.123456789', member: member)
    end

    it "should require authentication" do
      get "/api/v2/orders?market=cnybtc&state=wait&limit=20"
      response.code.should == '401'
    end

    it "should return orders" do
      signed_get '/api/v2/orders', params: {market: 'cnybtc', state: 'wait', limit: 20}, token: token
      response.should be_success
      JSON.parse(response.body).size.should == 2
    end

  end

end
