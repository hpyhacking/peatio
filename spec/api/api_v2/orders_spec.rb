require 'spec_helper'

describe APIv2::Orders do

  let(:member) { create(:member) }
  let(:token)  { create(:api_token, member: member) }

  describe "GET /api/v2/orders" do
    before do
      create(:order_bid, currency: 'btccny', price: '12.326'.to_d, volume: '123.123456789', member: member)
      create(:order_bid, currency: 'btccny', price: '12.326'.to_d, volume: '123.123456789', member: member, state: Order::CANCEL)
      create(:order_ask, currency: 'btccny', price: '12.326'.to_d, volume: '123.123456789', member: member)
      create(:order_ask, currency: 'btccny', price: '12.326'.to_d, volume: '123.123456789', member: member, state: Order::DONE)
    end

    it "should require authentication" do
      get "/api/v2/orders", market: 'btccny'
      response.code.should == '401'
    end

    it "should validate market param" do
      signed_get '/api/v2/orders', params: {market: 'mtgox'}, token: token
      response.code.should == '400'
      JSON.parse(response.body).should == {"error" => {"code" => 1001,"message" => "market does not have a valid value"}}
    end

    it "should validate state param" do
      signed_get '/api/v2/orders', params: {market: 'btccny', state: 'test'}, token: token
      response.code.should == '400'
      JSON.parse(response.body).should == {"error" => {"code" => 1001,"message" => "state does not have a valid value"}}
    end

    it "should return active orders by default" do
      signed_get '/api/v2/orders', params: {market: 'btccny'}, token: token
      response.should be_success
      JSON.parse(response.body).size.should == 2
    end

    it "should return complete orders" do
      signed_get '/api/v2/orders', params: {market: 'btccny', state: Order::DONE}, token: token
      response.should be_success
      JSON.parse(response.body).first['state'].should == Order::DONE
    end

  end

  describe "GET /api/v2/order" do
    let(:order) { create(:order_bid, currency: 'btccny', price: '12.326'.to_d, volume: '123.123456789', member: member) }

    it "should get specified order" do
      signed_get "/api/v2/order", params: {id: order.id}, token: token
      response.should be_success
      JSON.parse(response.body)['id'].should == order.id
    end

  end

  describe "POST /api/v2/orders" do

    it "should create a sell order" do
      member.get_account(:btc).update_attributes(balance: 100)
      member.get_account(:cny).update_attributes(balance: 100000)

      expect {
        signed_post '/api/v2/orders', token: token, params: {market: 'btccny', side: 'sell', volume: '12.13', price: '2014'}
        response.should be_success
        JSON.parse(response.body)['id'].should == OrderAsk.last.id
      }.to change(OrderAsk, :count).by(1)
    end

    it "should create a buy order" do
      member.get_account(:btc).update_attributes(balance: 100)
      member.get_account(:cny).update_attributes(balance: 100000)

      expect {
        signed_post '/api/v2/orders', token: token, params: {market: 'btccny', side: 'buy', volume: '12.13', price: '2014'}
        response.should be_success
        JSON.parse(response.body)['id'].should == OrderBid.last.id
      }.to change(OrderBid, :count).by(1)
    end

    it "should return cannot lock funds error" do
      expect {
        signed_post '/api/v2/orders', params: {market: 'btccny', side: 'sell', volume: '12.13', price: '2014'}
        response.code.should == '400'
        response.body.should == '{"error":{"code":2002,"message":"Failed to create order. Reason: cannot lock funds (amount: 12.13)"}}'
      }.not_to change(OrderAsk, :count).by(1)
    end

    it "should give a number as volume parameter" do
      signed_post '/api/v2/orders', params: {market: 'btccny', side: 'sell', volume: 'test', price: '2014'}
      response.code.should == '400'
      response.body.should == '{"error":{"code":2002,"message":"Failed to create order. Reason: Validation failed: Volume is not a number"}}'
    end

    it "should give a number as price parameter" do
      signed_post '/api/v2/orders', params: {market: 'btccny', side: 'sell', volume: '12.13', price: 'test'}
      response.code.should == '400'
      response.body.should == '{"error":{"code":2002,"message":"Failed to create order. Reason: Validation failed: Price must be greater than 0"}}'
    end

  end

end
