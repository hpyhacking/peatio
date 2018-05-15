# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Tickers, type: :request do
  describe 'GET /api/v2/tickers' do
    it 'returns ticker of all markets' do
      get '/api/v2/tickers'
      expect(response).to be_success
      expect(JSON.parse(response.body)['btcusd']['at']).not_to be_nil
      expect(JSON.parse(response.body)['btcusd']['ticker']).to eq ({ 'buy' => '0.0', 'sell' => '0.0', 'low' => '0.0', 'high' => '0.0', 'last' => '0.0', 'vol' => '0.0' })
    end
  end

  describe 'GET /api/v2/tickers/:market' do
    it 'should return market tickers' do
      get '/api/v2/tickers/btcusd'
      expect(response).to be_success
      expect(JSON.parse(response.body)['ticker']).to eq ({ 'buy' => '0.0', 'sell' => '0.0', 'low' => '0.0', 'high' => '0.0', 'last' => '0.0', 'vol' => '0.0' })
    end
  end
end
