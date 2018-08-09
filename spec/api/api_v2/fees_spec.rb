# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Fees, type: :request do
  describe 'GET /api/v2/fees/withdraw' do
    it 'returns withdraw fees for every enabled currency' do
      get '/api/v2/fees/withdraw'
      expect(response).to be_success

      result = JSON.parse(response.body)
      expect(result.size).to eq 8
    end

    it 'returns correct currency withdraw fee' do
      get '/api/v2/fees/withdraw'

      expect(response).to be_success

      result = JSON.parse(response.body)
      currency = result.find { |c| c['currency'] == 'usd' }
      withdraw_fee = Currency.find(:usd).withdraw_fee.to_s

      expect(currency.dig('currency')).to eq 'usd'
      expect(currency.dig('type')).to eq 'fiat'
      expect(currency.dig('fee', 'value')).to eq withdraw_fee
      expect(currency.dig('fee', 'type')).to eq 'fixed'
    end
  end

  describe 'GET /api/v2/fees/deposit' do
    it 'returns deposit fees for every enabled currency' do
      get '/api/v2/fees/deposit'
      expect(response).to be_success

      result = JSON.parse(response.body)
      expect(result.size).to eq 8
    end

    it 'returns correct currency deposit fee' do
      get '/api/v2/fees/deposit'

      expect(response).to be_success

      result = JSON.parse(response.body)
      currency = result.find { |c| c['currency'] == 'usd' }
      deposit_fee = Currency.find(:usd).deposit_fee.to_s

      expect(currency.dig('currency')).to eq 'usd'
      expect(currency.dig('type')).to eq 'fiat'
      expect(currency.dig('fee', 'value')).to eq deposit_fee
      expect(currency.dig('fee', 'type')).to eq 'fixed'
    end
  end

  describe 'GET /api/v2/fees/trading' do
    it 'returns trading fees for enabled markets' do
      get '/api/v2/fees/trading'
      expect(response).to be_success

      result = JSON.parse(response.body)
      expect(result.size).to eq Market.enabled.count
    end

    it 'returns correct trading fees' do
      get '/api/v2/fees/trading'

      expect(response).to be_success

      result = JSON.parse(response.body)
      market = result.find { |c| c['market'] == 'btcusd' }
      ask_fee = Market.find(:btcusd).ask_fee.to_s
      bid_fee = Market.find(:btcusd).bid_fee.to_s

      expect(market.dig('market')).to eq 'btcusd'
      expect(market.dig('ask_fee', 'type')).to eq 'relative'
      expect(market.dig('ask_fee', 'value')).to eq ask_fee
      expect(market.dig('bid_fee', 'type')).to eq 'relative'
      expect(market.dig('bid_fee', 'value')).to eq bid_fee
    end
  end
end
