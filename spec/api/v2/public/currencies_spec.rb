# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Public::Currencies, type: :request do

  before(:each) { clear_redis }
  describe 'GET /api/v2/public/currencies/:id' do
    let(:fiat) { Currency.find(:usd) }
    let(:coin) { Currency.find(:btc) }

    let(:expected) do
      %w[id description homepage type precision position price]
    end

    it 'returns information about specified currency' do
      get "/api/v2/public/currencies/#{coin.id}"
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq coin.id
    end

    context 'currency code with dot' do
      let!(:currency) { create(:currency, :xagm_cx) }

      it 'returns information about specified currency' do
        get "/api/v2/public/currencies/#{currency.id}"

        result = JSON.parse(response.body)
        expect(result.fetch('id')).to eq currency.id
      end
    end

    it 'returns correct keys for fiat' do
      get "/api/v2/public/currencies/#{fiat.id}"
      expect(response).to be_successful

      result = JSON.parse(response.body)

      expected.each { |key| expect(result).to have_key key }
    end

    it 'returns correct keys for coin' do
      get "/api/v2/public/currencies/#{coin.id}"
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expected.each { |key| expect(result).to have_key key }
    end

    it 'returns error in case of invalid id' do
      get '/api/v2/public/currencies/invalid'

      expect(response).to have_http_status 422
      expect(response).to include_api_error('public.currency.doesnt_exist')
    end
  end

  describe 'GET /api/v2/public/currencies' do
    it 'lists visible currencies' do
      get '/api/v2/public/currencies'
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.visible.size
    end

    it 'lists visible coins' do
      get '/api/v2/public/currencies', params: { type: 'coin' }
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.coins.visible.size
    end

    it 'lists visible fiats' do
      get '/api/v2/public/currencies', params: { type: 'fiat' }
      expect(response).to be_successful

      result = JSON.parse(response.body, symbolize_names: true)
      expect(result.size).to eq Currency.fiats.visible.size
      expect(result.dig(0, :id)).to eq 'usd'
    end

    it 'returns error in case of invalid type' do
      get '/api/v2/public/currencies', params: { type: 'invalid' }
      expect(response).to have_http_status 422
    end

    context 'pagination' do
      it 'returns paginated currencies' do
        get '/api/v2/public/currencies', params: { limit: 2 }

        result = JSON.parse(response.body)

        expect(response).to be_successful

        expect(response.headers.fetch('Total').to_i).to eq Currency.visible.count
        expect(result.size).to eq(2)
      end
    end

    context 'search' do
      it 'searches by code' do
        get '/api/v2/public/currencies', params: { search: { code: 't' } }

        expect(response).to be_successful
        result = JSON.parse(response.body)

        expect(result.pluck('id')).to contain_exactly('eth', 'btc', 'trst')
      end

      it 'searches by name' do
        get '/api/v2/public/currencies', params: { search: { name: 'e' } }

        expect(response).to be_successful
        result = JSON.parse(response.body)

        expect(result.pluck('name')).to contain_exactly('Ethereum', 'Evolution Land Global Token', 'WeTrust')
      end

      it 'searches by code or name' do
        get '/api/v2/public/currencies', params: { search: { name: 'us', code: 'us' } }

        expect(response).to be_successful
        result = JSON.parse(response.body)

        expect(result.pluck('id')).to contain_exactly('usd', 'trst')
        expect(result.pluck('name')).to contain_exactly('US Dollar', 'WeTrust')
      end
    end
  end
end
