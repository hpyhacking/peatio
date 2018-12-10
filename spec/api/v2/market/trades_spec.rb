# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Market::Trades, type: :request do
  let(:member) do
    create(:member, :level_3).tap do |m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:usd).update_attributes(balance: 2014.47, locked: 0)
    end
  end

  let(:token) { jwt_for(member) }

  let(:level_0_member) { create(:member, :level_0) }
  let(:level_0_member_token) { jwt_for(level_0_member) }

  let(:ask) do
    create(
      :order_ask,
      market_id: 'btcusd',
      price: '12.326'.to_d,
      volume: '123.123456789',
      member: member
    )
  end

  let(:bid) do
    create(
      :order_bid,
      market_id: 'btcusd',
      price: '12.326'.to_d,
      volume: '123.123456789',
      member: member
    )
  end

  let!(:ask_trade) { create(:trade, ask: ask, created_at: 2.days.ago) }
  let!(:bid_trade) { create(:trade, bid: bid, created_at: 1.day.ago) }

  describe 'GET /api/v2/market/trades' do
    it 'requires authentication' do
      get '/api/v2/market/trades', market: 'btcusd'

      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"Authorization failed"}}'
    end

    it 'returns all my recent trades' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: token
      expect(response).to be_success

      result = JSON.parse(response.body)

      expect(result.find { |t| t['id'] == ask_trade.id }['side']).to eq 'ask'
      expect(result.find { |t| t['id'] == ask_trade.id }['order_id']).to eq ask.id
      expect(result.find { |t| t['id'] == bid_trade.id }['side']).to eq 'bid'
      expect(result.find { |t| t['id'] == bid_trade.id }['order_id']).to eq bid.id
    end

    it 'returns 1 trade' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd', limit: 1 }, token: token

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'returns trades before timestamp' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd', timestamp: 30.hours.ago.to_i }, token: token

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'returns limit out of range error' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd', limit: 1024 }, token: token

      expect(response.code).to eq '422'
      expect(response.body).to eq '{"error":{"code":1001,"message":"limit must be in range: 1..1000."}}'
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: level_0_member_token
      expect(response.code).to eq '401'
      expect(JSON.parse(response.body)['error']).to eq( {'code' => 2000, 'message' => 'Please, pass the corresponding verification steps to enable trading.'} )
    end

  end
end
