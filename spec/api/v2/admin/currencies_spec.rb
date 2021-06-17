# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Currencies, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/currencies/:code' do
    let(:fiat) { Currency.find(:usd) }
    let(:coin) { Currency.find(:btc) }

    let(:expected) do
      %w[name description homepage code type precision status position price]
    end

    it 'returns information about specified currency' do
      api_get "/api/v2/admin/currencies/#{coin.code}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('code')).to eq coin.code
    end

    it 'returns correct keys for fiat' do
      api_get "/api/v2/admin/currencies/#{fiat.code}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expected.each { |key| expect(result).to have_key key }
    end

    context 'currency code with dot' do
      let!(:currency) { create(:currency, :xagm_cx) }

      it 'returns information about specified currency' do
        api_get "/api/v2/admin/currencies/#{currency.code}", token: token

        result = JSON.parse(response.body)
        expect(result.fetch('code')).to eq currency.code
      end
    end

    it 'returns correct keys for coin' do
      api_get "/api/v2/admin/currencies/#{coin.code}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expected.each { |key| expect(result).to have_key key }
    end

    it 'returns ordered by position currencies' do
      api_get "/api/v2/admin/currencies/", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.pluck('position')).to eq Currency.ordered.pluck(:position)
    end

    it 'returns error in case of invalid code' do
      api_get '/api/v2/admin/currencies/invalid', token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.doesnt_exist')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/currencies/#{coin.code}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'GET /api/v2/admin/currencies' do
    it 'list of currencies' do
      api_get '/api/v2/admin/currencies', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.count
    end

    it 'list of coins' do
      api_get '/api/v2/admin/currencies', params: { type: 'coin' }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.coins.size
    end

    it 'list of fiats' do
      api_get '/api/v2/admin/currencies', params: { type: 'fiat' }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body, symbolize_names: true)
      expect(result.size).to eq Currency.fiats.size
      expect(result.dig(0, :code)).to eq 'usd'
    end

    it 'list of visible currencies' do
      api_get '/api/v2/admin/currencies', params: { status: :enabled }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.visible.count
    end

    it 'list of not visible currencies' do
      api_get '/api/v2/admin/currencies', params: { status: :disabled }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.where(status: :disabled).count
    end

    it 'returns error in case of invalid visible type' do
      api_get '/api/v2/admin/currencies', params: { status: 'invalid' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.invalid_status')
    end

    it 'list of visible coins' do
      api_get '/api/v2/admin/currencies', params: { status: :enabled, type: 'coin' }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.coins.select { |c| c['status'] == 'enabled' }.count
    end

    it 'list of not visible coins' do
      api_get '/api/v2/admin/currencies', params: { status: :disabled, type: 'coin' }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.coins.where(status: :disabled).count
    end

    it 'returns error in case of invalid type' do
      api_get '/api/v2/admin/currencies', params: { type: 'invalid' }, token: token
      expect(response).to have_http_status 422
    end

    it 'returns currencies by ascending order' do
      api_get '/api/v2/admin/currencies', params: { ordering: 'asc', order_by: 'code'}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['code']).to eq 'btc'
    end

    it 'returns paginated currencies' do
      api_get '/api/v2/admin/currencies', params: { limit: 3, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '6'
      expect(result.size).to eq 3
      expect(result.first['code']).to eq 'usd'

      api_get '/api/v2/admin/currencies', params: { limit: 3, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '6'
      expect(result.size).to eq 3
      expect(result.first['code']).to eq 'eth'
    end

    it 'return error in case of not permitted ability' do
      api_get '/api/v2/admin/currencies', token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/currencies/new' do
    it 'create coin' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['type']).to eq 'coin'
    end

    it 'create fiat' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', type: 'fiat' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['type']).to eq 'fiat'
    end

    it 'validate type param' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', type: 'test'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.invalid_type')
    end

    it 'validate visible param' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', type: 'fiat', status: '123'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.invalid_status')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/currencies/new', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.missing_code')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', blockchain_key: 'btc-testnet' }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/currencies/update' do
    context 'permissions' do
      let(:support) { create(:member, :admin, :level_3, role: :support, email: 'example@gmail.com', uid: 'ID73BF61C8H1') }
      let(:support_token) { jwt_for(support) }

      it 'return error in case of not permitted ability' do
        api_post '/api/v2/admin/currencies/update', params: { code: Currency.find_by(type: 'fiat').code, precision: 1 }, token: support_token

        expect(response.code).to eq '403'
        expect(response).to include_api_error('admin.ability.not_permitted')
      end

      it 'updates fiat' do
        api_post '/api/v2/admin/currencies/update', params: { code: Currency.find_by(type: 'fiat').code, name: 'Test' }, token: token
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result['name']).to eq 'Test'
      end
    end

    it 'update fiat' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.find_by(type: 'fiat').code, description: 'test' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['description']).to eq 'test'
    end

    it 'update coin' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.find_by(type: 'coin').code, description: 'test' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['description']).to eq 'test'
    end

    it 'validate position param' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.find_by(type: 'coin').code, position: 0 }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.invalid_position')
    end

    it 'validate visible param' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.first.id, status: '123' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.invalid_status')
    end

    it 'validates negative precision' do
      expect {
        api_post '/api/v2/admin/currencies/update', params: { code: Currency.first.id, precision: -1 }, token: token
      }.not_to change { Currency.first }

      expect(response).not_to be_successful
      expect(response.status).to eq 422
    end

    it 'checked required params' do
      api_post '/api/v2/admin/currencies/update', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.missing_code')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.first.id }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end
end
