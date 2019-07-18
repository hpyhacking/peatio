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

  let(:btcusd_ask) do
    create(
      :order_ask,
      :btcusd,
      price: '12.32'.to_d,
      volume: '123.12345678',
      member: member
    )
  end

  let(:btceth_ask) do
    create(
      :order_ask,
      :btceth,
      price: '12.32'.to_d,
      volume: '123.1234',
      member: member
    )
  end

  let(:btcusd_bid) do
    create(
      :order_bid,
      :btcusd,
      price: '12.32'.to_d,
      volume: '123.12345678',
      member: member
    )
  end

  let(:btceth_bid) do
    create(
      :order_bid,
      :btceth,
      price: '12.32'.to_d,
      volume: '123.1234',
      member: member
    )
  end

  let!(:btcusd_ask_trade) { create(:trade, :btcusd, ask: btcusd_ask, created_at: 2.days.ago) }
  let!(:btceth_ask_trade) { create(:trade, :btceth, ask: btceth_ask, created_at: 2.days.ago) }
  let!(:btcusd_bid_trade) { create(:trade, :btcusd, bid: btcusd_bid, created_at: 23.hours.ago) }
  let!(:btceth_bid_trade) { create(:trade, :btceth, bid: btceth_bid, created_at: 23.hours.ago) }

  describe 'GET /api/v2/market/trades' do
    it 'requires authentication' do
      get '/api/v2/market/trades', params: { market: 'btcusd' }
      expect(response.code).to eq '401'
      expect(response).to include_api_error('jwt.decode_and_verify')
    end

    it 'returns all my recent trades' do
      api_get '/api/v2/market/trades', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)

      expect(response.headers.fetch('Total')).to eq '4'

      expect(result.find { |t| t['id'] == btcusd_ask_trade.id }['side']).to eq 'ask'
      expect(result.find { |t| t['id'] == btcusd_ask_trade.id }['order_id']).to eq btcusd_ask.id
      expect(result.find { |t| t['id'] == btceth_ask_trade.id }['side']).to eq 'ask'
      expect(result.find { |t| t['id'] == btceth_ask_trade.id }['order_id']).to eq btceth_ask.id
      expect(result.find { |t| t['id'] == btcusd_bid_trade.id }['side']).to eq 'bid'
      expect(result.find { |t| t['id'] == btcusd_bid_trade.id }['order_id']).to eq btcusd_bid.id
      expect(result.find { |t| t['id'] == btceth_bid_trade.id }['side']).to eq 'bid'
      expect(result.find { |t| t['id'] == btceth_bid_trade.id }['order_id']).to eq btceth_bid.id
    end

    it 'returns all my recent trades for btcusd market' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)

      expect(response.headers.fetch('Total')).to eq '2'
      expect(result.find { |t| t['id'] == btcusd_ask_trade.id }['side']).to eq 'ask'
      expect(result.find { |t| t['id'] == btcusd_ask_trade.id }['order_id']).to eq btcusd_ask.id
      expect(result.find { |t| t['id'] == btcusd_bid_trade.id }['side']).to eq 'bid'
      expect(result.find { |t| t['id'] == btcusd_bid_trade.id }['order_id']).to eq btcusd_bid.id
    end

    it 'returns 1 trade' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd', limit: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 1
      expect(response.headers.fetch('Total')).to eq '2'
    end

    it 'returns trades for last 24h' do
      create(:trade, :btcusd, ask_member: member, created_at: 6.hours.ago)
      api_get '/api/v2/market/trades', params: { time_from: 1.day.ago.to_i }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 3
      expect(response.headers.fetch('Total')).to eq '3'
    end

    it 'returns trades older than 1 day' do
      api_get '/api/v2/market/trades', params: { time_to: 1.day.ago.to_i }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 2
      expect(response.headers.fetch('Total')).to eq '2'
    end

    it 'returns trades for specific hour' do
      create(:trade, :btcusd, ask_member: member, created_at: 6.hours.ago)
      api_get '/api/v2/market/trades', params: { time_from: 7.hours.ago.to_i, time_to: 5.hours.ago.to_i }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 1
      expect(response.headers.fetch('Total')).to eq '1'
    end

    it 'returns limit out of range error' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd', limit: 1024 }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('market.trade.invalid_limit')
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/market/trades', params: { market: 'btcusd' }, token: level_0_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('market.trade.not_permitted')
    end
  end
end
