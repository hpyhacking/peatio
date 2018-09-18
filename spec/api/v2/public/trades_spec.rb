# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Public::Markets, type: :request do
  let(:member) do
    create(:member, :level_3).tap do |m|
      m.get_account(:btc).update_attributes(balance: 12.13,   locked: 3.14)
      m.get_account(:usd).update_attributes(balance: 2014.47, locked: 0)
    end
  end

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

  let(:market) { :btcusd }

  let!(:ask_trade) { create(:trade, ask: ask, created_at: 2.days.ago) }
  let!(:bid_trade) { create(:trade, bid: bid, created_at: 1.day.ago) }

  describe 'GET /api/v2/public/markets/#{market}/trades' do
    it 'should return all recent trades' do
      get "/api/v2/public/markets/#{market}/trades"

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 2
    end

    it 'should return 1 trade' do
      get "/api/v2/public/markets/#{market}/trades", limit: 1

      expect(response).to be_success
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'should return trades before timestamp' do
      create(:trade, bid: bid, created_at: 6.hours.ago)

      get "/api/v2/public/markets/#{market}/trades", timestamp: 8.hours.ago.to_i, limit: 1
      expect(response).to be_success

      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      expect(json.first['id']).to eq bid_trade.id
    end

    it 'should return trades between id range' do
      another = create(:trade, bid: bid)

      get "/api/v2/public/markets/#{market}/trades", from: ask_trade.id, to: another.id
      expect(response).to be_success

      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      expect(json.first['id']).to eq bid_trade.id
    end

    it 'should sort trades in reverse creation order' do
      get "/api/v2/public/markets/#{market}/trades"

      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq bid_trade.id
    end

    it 'should get trades by from and limit' do
      create(:trade, bid: bid, created_at: 6.hours.ago)

      get "/api/v2/public/markets/#{market}/trades", from: ask_trade.id, limit: 1, order_by: 'asc'

      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq bid_trade.id
    end

    it 'should validate market param' do
      api_get "/api/v2/public/markets/usdusd/trades"
      expect(response).to have_http_status 422
      expect(JSON.parse(response.body)).to eq ({ 'error' => { 'code' => 1001, 'message' => 'market does not have a valid value' } })
    end

    it 'should validate from and to param' do
      another = create(:trade, bid: bid)

      get "/api/v2/public/markets/#{market}/trades", from: another.id, to: ask_trade.id
      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"from should be less than to."}}'
    end

    # it 'should validate from and to params without market' do
    #   another = create(:trade, bid: bid)

    #   get "/api/v2/public/markets/#{market}/trades", from: ask_trade.id, to: another.id
    #   expect(response).to have_http_status 422
    #   expect(response.body).to eq '{"error":{"code":1001,"message":"market is missing, market does not have a valid value"}}'
    # end

    it 'should validate from and to params with negative value' do
      another = create(:trade, bid: bid)

      get "/api/v2/public/markets/#{market}/trades", from: -(ask_trade.id), to: -(another.id)
      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"from is invalid, from should be less than to., to is invalid"}}'
    end

    it 'should validate value of from' do
      get "/api/v2/public/markets/#{market}/trades", from: -(ask_trade.id)

      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"from is invalid"}}'
    end

    it 'should validate value of to' do
      another = create(:trade, bid: bid)

      get "/api/v2/public/markets/#{market}/trades", to: -(another.id)
      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"to is invalid"}}'
    end

    it 'should validate empty value of from' do
      get "/api/v2/public/markets/#{market}/trades", from: nil

      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"from is empty"}}'
    end

    it 'should validate empty value of to' do
      get "/api/v2/public/markets/#{market}/trades", to: nil

      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"to is empty"}}'
    end

    it 'should validate missing value of from and to' do
      get "/api/v2/public/markets/#{market}/trades", from: '', to: ''

      expect(response).to have_http_status 422
      expect(response.body).to eq '{"error":{"code":1001,"message":"from should be less than to., from is empty, to is empty"}}'
    end
  end
end
