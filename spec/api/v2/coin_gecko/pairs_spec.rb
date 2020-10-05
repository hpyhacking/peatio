# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::CoinGecko::Pairs, type: :request do
  describe 'GET /api/v2/coingecko/pairs' do
    before(:each) { clear_redis }

    let!(:market) do
      ::Market.enabled.ordered.sample
    end

    let!(:expected_response) {
      {
          "ticker_id" => market.underscore_name,
          "base"      => market[:base_unit].upcase,
          "target"    => market[:quote_unit].upcase
      }
    }

    it 'lists visible currencies' do
      get '/api/v2/coingecko/pairs'
      expect(response).to be_successful

      result = JSON.parse(response.body)

      expect(result.size).to eq Market.enabled.size
      expect(result).to include(expected_response)
    end
  end

  context 'There is no markets' do
    before { DatabaseCleaner.clean }

    it 'should return summary' do
      get '/api/v2/coingecko/pairs'

      expect(response).to be_successful
      result = JSON.parse(response.body)
      expect(result).to eq []
    end
  end
end
