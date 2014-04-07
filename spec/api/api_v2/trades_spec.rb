require 'spec_helper'

describe APIv2::Trades do

  let(:member) do
    create(:verified_member).tap {|m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:cny).update_attributes(balance: 2014.47, locked: 0)
    }
  end
  let(:token)  { create(:api_token, member: member) }

  describe 'GET /api/v2/trades' do
    let(:ask) { create(:order_ask, currency: 'btccny', price: '12.326'.to_d, volume: '123.123456789', member: member) }
    let(:bid) { create(:order_bid, currency: 'btccny', price: '12.326'.to_d, volume: '123.123456789', member: member) }

    let!(:ask_trade) { create(:trade, ask: ask, created_at: 2.days.ago) }
    let!(:bid_trade) { create(:trade, bid: bid, created_at: 1.day.ago) }

    it "should require authentication" do
      get '/api/v2/trades', market: 'btccny'
      response.code.should == '401'
      response.body.should == '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it "should return all my recent trades" do
      signed_get '/api/v2/trades', params: {market: 'btccny', shit: '1'}, token: token
      response.should be_success

      result = JSON.parse(response.body)
      result.find {|t| t['id'] == ask_trade.id }['side'].should == 'ask'
      result.find {|t| t['id'] == bid_trade.id }['side'].should == 'bid'
    end

    it "should return 1 trade" do
      signed_get '/api/v2/trades', params: {market: 'btccny', limit: 1}, token: token
      response.should be_success
      JSON.parse(response.body).should have(1).trade
    end

    it "should return trades after timestamp" do
      signed_get '/api/v2/trades', params: {market: 'btccny', timestamp: 30.hours.ago.to_i}, token: token
      response.should be_success
      JSON.parse(response.body).first['id'].should == bid_trade.id
    end
  end

end
