# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Trades, type: :request do
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

  describe 'GET /api/v2/trades' do
    it 'should return all recent trades' do
      get '/api/v2/trades', market: 'btcusd'

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 2
    end

    it 'should return 1 trade' do
      get '/api/v2/trades', market: 'btcusd', limit: 1

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'should return trades before timestamp' do
      create(:trade, bid: bid, created_at: 6.hours.ago)

      get '/api/v2/trades', market: 'btcusd', timestamp: 8.hours.ago.to_i, limit: 1
      expect(response).to be_success

      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      expect(json.first['id']).to eq bid_trade.id
    end

    it 'should return trades between id range' do
      another = create(:trade, bid: bid)

      get '/api/v2/trades', market: 'btcusd', from: ask_trade.id, to: another.id
      expect(response).to be_success

      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      expect(json.first['id']).to eq bid_trade.id
    end

    it 'should sort trades in reverse creation order' do
      get '/api/v2/trades', market: 'btcusd'

      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq bid_trade.id
    end

    it 'should get trades by from and limit' do
      create(:trade, bid: bid, created_at: 6.hours.ago)

      get '/api/v2/trades', market: 'btcusd', from: ask_trade.id, limit: 1, order_by: 'asc'

      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq bid_trade.id
    end

    it 'should validate market param' do
      api_get '/api/v2/trades', params: { market: 'usdusd'}
      expect(response).to have_http_status 422
      expect(JSON.parse(response.body)).to eq ({ 'error' => { 'code' => 1001, 'message' => 'market does not have a valid value' } })
    end

    it 'should validate from and to param' do
      another = create(:trade, bid: bid)

      get '/api/v2/trades', market: 'btcusd', from: another.id, to: ask_trade.id
      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"from should be less than to."}}'
    end

    it 'should validate from and to params without market' do
      another = create(:trade, bid: bid)

      get '/api/v2/trades', from: ask_trade.id, to: another.id
      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"market is missing, market does not have a valid value"}}'
    end

    it 'should validate from and to params with negative value' do
      another = create(:trade, bid: bid)

      get '/api/v2/trades', market: 'btcusd', from: -(ask_trade.id), to: -(another.id)
      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"from is invalid, from should be less than to., to is invalid"}}'
    end

    it 'should validate value of from' do
      get '/api/v2/trades', market: 'btcusd', from: -(ask_trade.id)

      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"from is invalid"}}'
    end

    it 'should validate value of to' do
      another = create(:trade, bid: bid)

      get '/api/v2/trades', market: 'btcusd', to: -(another.id)
      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"to is invalid"}}'
    end

    it 'should validate empty value of from' do
      get '/api/v2/trades', market: 'btcusd', from: nil

      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"from is empty"}}'
    end

    it 'should validate empty value of to' do
      get '/api/v2/trades', market: 'btcusd', to: nil

      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"to is empty"}}'
    end

    it 'should validate missing value of from and to' do
      get '/api/v2/trades', market: 'btcusd', from: '', to: ''

      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"from should be less than to., from is empty, to is empty"}}'
    end
  end

  describe 'GET /api/v2/trades/my' do
    it 'should require authentication' do
      get '/api/v2/trades/my', market: 'btcusd'

      expect(response.code).to eq '401'
      expect(response.body).to eq '{"error":{"code":2001,"message":"2001: Authorization failed"}}'
    end

    it 'should return all my recent trades' do
      api_get '/api/v2/trades/my', params: { market: 'btcusd' }, token: token
      expect(response).to be_success

      result = JSON.parse(response.body)

      expect(result.find { |t| t['id'] == ask_trade.id }['side']).to eq 'ask'
      expect(result.find { |t| t['id'] == ask_trade.id }['order_id']).to eq ask.id
      expect(result.find { |t| t['id'] == bid_trade.id }['side']).to eq 'bid'
      expect(result.find { |t| t['id'] == bid_trade.id }['order_id']).to eq bid.id
    end

    it 'should return 1 trade' do
      api_get '/api/v2/trades/my', params: { market: 'btcusd', limit: 1 }, token: token

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'should return trades before timestamp' do
      api_get '/api/v2/trades/my', params: { market: 'btcusd', timestamp: 30.hours.ago.to_i }, token: token

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'should return limit out of range error' do
      api_get '/api/v2/trades/my', params: { market: 'btcusd', limit: 1024 }, token: token

      expect(response.code).to eq '422'
      expect(response.body).to eq '{"error":{"code":1001,"message":"limit must be in range: 1..1000."}}'
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/trades/my', params: { market: 'btcusd' }, token: level_0_member_token
      expect(response.code).to eq '401'
      expect(JSON.parse(response.body)['error']).to eq( {'code' => 2000, 'message' => 'Please, pass the corresponding verification steps to enable trading.'} )
    end

    it 'should validate market param' do
      api_get '/api/v2/trades', params: { market: 'usdusd'}, token: token
      expect(response).to have_http_status 422
      expect(JSON.parse(response.body)).to eq ({ 'error' => { 'code' => 1001, 'message' => 'market does not have a valid value' } })
    end

  end
end
