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
    let(:order)  { create(:order_bid, currency: 'btccny', price: '12.326'.to_d, volume: '3.14', origin_volume: '12.13', member: member) }
    let!(:trade) { create(:trade, bid: order) }

    it "should get specified order" do
      signed_get "/api/v2/order", params: {id: order.id}, token: token
      response.should be_success

      result = JSON.parse(response.body)
      result['id'].should == order.id
      result['executed_volume'].should == '8.99'
    end

    it "should include related trades" do
      signed_get "/api/v2/order", params: {id: order.id}, token: token

      result = JSON.parse(response.body)
      result['trades'].should have(1).trade
      result['trades'].first['id'].should == trade.id
      result['trades'].first['side'].should == 'buy'
    end
  end

  describe "POST /api/v2/orders/multi" do
    before do
      member.get_account(:btc).update_attributes(balance: 100)
      member.get_account(:cny).update_attributes(balance: 100000)
    end

    it "should create a sell order and a buy order" do
      params = {
        market: 'btccny',
        orders: [
          {side: 'sell', volume: '12.13', price: '2014'},
          {side: 'buy',  volume: '17.31', price: '2005'}
        ]
      }

      expect {
        signed_post '/api/v2/orders/multi', token: token, params: params
        response.should be_success

        result = JSON.parse(response.body)
        result.should have(2).orders
        result.first['side'].should   == 'sell'
        result.first['volume'].should == '12.13'
        result.last['side'].should    == 'buy'
        result.last['volume'].should  == '17.31'
      }.to change(Order, :count).by(2)
    end

    it "should create nothing on error" do
      params = {
        market: 'btccny',
        orders: [
          {side: 'sell', volume: '12.13', price: '2014'},
          {side: 'buy',  volume: '17.31', price: 'test'} # <- invalid price
        ]
      }

      expect {
        signed_post '/api/v2/orders/multi', token: token, params: params
        response.code.should == '400'
        response.body.should == '{"error":{"code":2002,"message":"Failed to create order. Reason: Validation failed: Price must be greater than 0"}}'
      }.not_to change(Order, :count)
    end
  end

  describe "POST /api/v2/orders" do
    it "should create a sell order" do
      member.get_account(:btc).update_attributes(balance: 100)

      expect {
        signed_post '/api/v2/orders', token: token, params: {market: 'btccny', side: 'sell', volume: '12.13', price: '2014'}
        response.should be_success
        JSON.parse(response.body)['id'].should == OrderAsk.last.id
      }.to change(OrderAsk, :count).by(1)
    end

    it "should create a buy order" do
      member.get_account(:cny).update_attributes(balance: 100000)

      expect {
        signed_post '/api/v2/orders', token: token, params: {market: 'btccny', side: 'buy', volume: '12.13', price: '2014'}
        response.should be_success
        JSON.parse(response.body)['id'].should == OrderBid.last.id
      }.to change(OrderBid, :count).by(1)
    end

    it "should set order source to APIv2" do
      member.get_account(:cny).update_attributes(balance: 100000)
      signed_post '/api/v2/orders', token: token, params: {market: 'btccny', side: 'buy', volume: '12.13', price: '2014'}
      OrderBid.last.source.should == 'APIv2'
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
      response.body.should == '{"error":{"code":2002,"message":"Failed to create order. Reason: Validation failed: Volume must be greater than 0"}}'
    end

    it "should give a number as price parameter" do
      signed_post '/api/v2/orders', params: {market: 'btccny', side: 'sell', volume: '12.13', price: 'test'}
      response.code.should == '400'
      response.body.should == '{"error":{"code":2002,"message":"Failed to create order. Reason: Validation failed: Price must be greater than 0"}}'
    end
  end

  describe "POST /api/v2/order/delete" do
    let!(:order)  { create(:order_bid, currency: 'btccny', price: '12.326'.to_d, volume: '3.14', origin_volume: '12.13', locked: '20.1082', origin_locked: '38.0882', member: member) }

    context "succesful" do
      before do
        member.get_account(:cny).update_attributes(locked: order.price*order.volume)
      end

      it "should cancel specified order" do
        expect {
          signed_post "/api/v2/order/delete", params: {id: order.id}, token: token
          response.should be_success
          JSON.parse(response.body)['id'].should == order.id
          order.reload.state.should == Order::CANCEL
        }.not_to change(Order, :count)
      end

      it "should include executed and remaining amount in result" do
        signed_post "/api/v2/order/delete", params: {id: order.id}, token: token
        result = JSON.parse(response.body)
        result['volume'].should == '12.13'
        result['remaining_volume'].should == '3.14'
        result['executed_volume'].should == '8.99'
        result['avg_price'].should == '2.0'
      end
    end

    context "failed" do
      it "should return error" do
        signed_post "/api/v2/order/delete", params: {id: order.id}, token: token
        response.code.should == '400'
        response.body.should == '{"error":{"code":2003,"message":"Failed to cancel order. Reason: cannot unlock funds (amount: 20.1082)"}}'
      end
    end

  end

  describe "POST /api/v2/orders/clear" do

    before do
      create(:order_ask, currency: 'btccny', price: '12.326', volume: '3.14', origin_volume: '12.13', member: member)
      create(:order_bid, currency: 'btccny', price: '12.326', volume: '3.14', origin_volume: '12.13', member: member)

      member.get_account(:btc).update_attributes(locked: '5')
      member.get_account(:cny).update_attributes(locked: '50')
    end

    it "should cancel all my orders" do
      expect {
        signed_post "/api/v2/orders/clear", token: token
        response.should be_success

        result = JSON.parse(response.body)
        result.should have(2).orders
        result.each {|o| Order.find(o['id']).state.should == Order::CANCEL }
      }.not_to change(Order, :count)
    end

  end
end
