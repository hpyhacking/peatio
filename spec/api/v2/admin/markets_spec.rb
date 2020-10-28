# frozen_string_literal: true

describe API::V2::Admin::Markets, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/markets/:id' do
    let(:market) { Market.find_by(id: 'btcusd') }

    it 'returns information about specified market' do
      api_get "/api/v2/admin/markets/#{market.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq market.id
      expect(result.fetch('base_unit')).to eq market.base_currency
      expect(result.fetch('quote_unit')).to eq market.quote_currency
      expect(result.fetch('data')).to eq market.data
    end

    it 'returns ordered by position currencies' do
      api_get "/api/v2/admin/markets/", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.pluck('position')).to eq Market.ordered.pluck(:position)
    end

    context 'market name with dot' do
      let!(:currency) { create(:currency, :xagm_cx) }
      let!(:market) { create(:market, :xagm_cxusd) }

      it 'returns information about specified market' do
        api_get "/api/v2/admin/markets/#{market.id}", token: token

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result.fetch('id')).to eq market.id
        expect(result.fetch('base_unit')).to eq market.base_currency
        expect(result.fetch('quote_unit')).to eq market.quote_currency
        expect(result.fetch('data')).to eq market.data
      end
    end

    it 'returns error in case of invalid id' do
      api_get '/api/v2/admin/markets/120', token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/markets/#{market.id}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'GET /api/v2/admin/markets' do
    it 'lists of markets' do
      api_get '/api/v2/admin/markets', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq 2
    end

    it 'returns markets by ascending order' do
      api_get '/api/v2/admin/markets', params: { ordering: 'asc', order_by: 'quote_currency' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['quote_unit']).to eq 'eth'
    end

    it 'returns paginated markets' do
      api_get '/api/v2/admin/markets', params: { limit: 1, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '2'
      expect(result.size).to eq 1
      expect(result.first['id']).to eq 'btcusd'

      api_get '/api/v2/admin/markets', params: { limit: 1, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '2'
      expect(result.size).to eq 1
      expect(result.first['id']).to eq 'btceth'
    end

    it 'return error in case of not permitted ability' do
      api_get '/api/v2/admin/markets', token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/markets/new' do
    let(:engine) { create(:engine) }
    let(:valid_params) do
      {
        base_currency: 'trst',
        quote_currency: 'btc',
        engine_id: engine.id,
        price_precision: 2,
        amount_precision: 2,
        min_price: 0.01,
        min_amount: 0.01,
        data: {
          upstream: {
            driver: :opendax
          }
        }
      }
    end

    it 'creates new market' do
      api_post '/api/v2/admin/markets/new', token: token, params: valid_params
      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['id']).to eq 'trstbtc'
      expect(result['engine_id']).to eq Market.last.engine_id
      expect(result['data']).to eq({ 'upstream' => { 'driver' => 'opendax' } })
    end

    it 'create new market with engine name param' do
      api_post '/api/v2/admin/markets/new', token: token, params: valid_params.except(:engine_id).merge(engine_name: engine.name)
      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['id']).to eq 'trstbtc'
      expect(result['engine_id']).to eq Market.last.engine_id
      expect(result['data']).to eq({ 'upstream' => { 'driver' => 'opendax' } })
    end

    it 'validate base_currency param' do
      api_post '/api/v2/admin/markets/new', token: token, params: valid_params.merge(base_currency: 'test')

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.currency_doesnt_exist')
    end

    it 'validate quote_currency param' do
      api_post '/api/v2/admin/markets/new', token: token, params: valid_params.merge(quote_currency: 'test')

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.currency_doesnt_exist')
    end

    it 'validate enabled param' do
      api_post '/api/v2/admin/markets/new', token: token, params: valid_params.merge(state: '123')

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.invalid_state')
    end

    it 'validate engine name param' do
      api_post '/api/v2/admin/markets/new', token: token, params: valid_params.except(:engine_id).merge(engine_name: 'test')

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.engine_doesnt_exist')
    end

    it 'checked exactly_one_ofr params' do
      api_post '/api/v2/admin/markets/new', token: token, params: valid_params.merge(engine_name: 'test')

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.one_of_engine_id_engine_name_fields')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/markets/new', params: {}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.missing_base_currency')
      expect(response).to include_api_error('admin.market.missing_quote_currency')
      expect(response).to include_api_error('admin.market.one_of_engine_id_engine_name_fields')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/markets/new', params: valid_params, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/markets/update' do
    it 'updates attributes' do
      api_post '/api/v2/admin/markets/update', params: { id: Market.first.id, amount_precision: 3, price_precision: 5, min_amount: 0.1, min_price: 0.1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['amount_precision']).to eq 3
      expect(result['price_precision']).to eq 5
      expect(result['min_amount']).to eq '0.1'
      expect(result['min_price']).to eq '0.1'
    end

    it 'updates data' do
      api_post '/api/v2/admin/markets/update', params: { id: Market.first.id, data: { 'upstream' => { 'driver' => 'opendax' } } }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['data']).to eq({ 'upstream' => { 'driver' => 'opendax' } })
    end

    it 'validates data field' do
      api_post '/api/v2/admin/markets/update', params: { id: Market.first.id, data: 'data' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.invalid_data')
    end

    it 'validates position' do
      api_post '/api/v2/admin/markets/update', params: { id: Market.first.id, position: 0 }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.invalid_position')
    end

    it 'checkes required params' do
      api_post '/api/v2/admin/markets/update', params: {}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.market.missing_id')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/markets/update', params: { id: Market.first.id, state: :disabled }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end
end
