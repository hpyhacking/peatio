require 'spec_helper'

describe APIv2::Orders do

  describe "GET /api/v2/orders" do

    let(:member) { create(:member) }
    let(:token)  { create(:api_token, member: member) }

    before do
      create(:order_bid, currency: 'cnybtc', price: '12.326'.to_d, volume: '123.123456789', member: member)
      create(:order_bid, currency: 'cnybtc', price: '12.326'.to_d, volume: '123.123456789', member: member, state: Order::CANCEL)
      create(:order_ask, currency: 'cnybtc', price: '12.326'.to_d, volume: '123.123456789', member: member)
      create(:order_ask, currency: 'cnybtc', price: '12.326'.to_d, volume: '123.123456789', member: member, state: Order::DONE)
    end

    it "should require authentication" do
      get "/api/v2/orders", market: 'cnybtc'
      response.code.should == '401'
    end

    it "should validate market param" do
      signed_get '/api/v2/orders', params: {market: 'mtgox'}, token: token
      response.code.should == '400'
      JSON.parse(response.body).should == {"error" => {"code" => 1001,"message" => "market does not have a valid value"}}
    end

    it "should validate state param" do
      signed_get '/api/v2/orders', params: {market: 'cnybtc', state: 'test'}, token: token
      response.code.should == '400'
      JSON.parse(response.body).should == {"error" => {"code" => 1001,"message" => "state does not have a valid value"}}
    end

    it "should return active orders by default" do
      signed_get '/api/v2/orders', params: {market: 'cnybtc'}, token: token
      response.should be_success

      result = JSON.parse(response.body)
      result.size.should == 2
    end

    it "should return complete orders" do
      signed_get '/api/v2/orders', params: {market: 'cnybtc', state: Order::DONE}, token: token
      response.should be_success
      JSON.parse(response.body).first['state'].should == Order::DONE
    end

  end

end
