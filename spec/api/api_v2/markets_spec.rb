# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Markets, type: :request do
  describe 'GET /api/v2/markets' do
    let(:expected_markets) do
      [
        {"id"=>"btcusd", "name"=>"BTC/USD"},
        {"id"=>"dashbtc", "name"=>"DASH/BTC"},
        {"id"=>"btceth", "name"=>"BTC/ETH"},
        {"id"=>"btcxrp", "name"=>"BTC/XRP"}
      ]
    end

    it 'lists enabled markets' do
      get '/api/v2/markets'
      expect(response).to be_success
      expect(JSON.parse(response.body)).to eq expected_markets
    end
  end
end
