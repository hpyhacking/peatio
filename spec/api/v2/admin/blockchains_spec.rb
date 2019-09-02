# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Blockchains, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/blockchains/:id' do
    let(:blockchain) { Blockchain.find_by(key: "eth-rinkeby") }

    it 'returns information about specified blockchain' do
      api_get "/api/v2/admin/blockchains/#{blockchain.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq blockchain.id
      expect(result.fetch('name')).to eq blockchain.name
    end

    it 'returns error in case of invalid id' do
      api_get "/api/v2/admin/blockchains/#{Blockchain.last.id + 42}", token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/blockchains/#{blockchain.id}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'GET /api/v2/admin/blockchains/clients' do
    it 'get list of all available clients' do
      api_get '/api/v2/admin/blockchains/clients', token: token
      expect(JSON.parse(response.body)).to match_array Blockchain.clients.map &:to_s
    end
  end

  describe 'GET /api/v2/admin/blockchains' do
    it 'lists of blockchains' do
      api_get '/api/v2/admin/blockchains', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq 3
    end

    it 'returns blockchains by ascending order' do
      api_get '/api/v2/admin/blockchains', params: { ordering: 'asc', order_by: 'client'}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['client']).to eq 'bitcoin'
    end

    it 'returns paginated blockchains' do
      api_get '/api/v2/admin/blockchains', params: { limit: 2, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '3'
      expect(result.size).to eq 2
      expect(result.first['key']).to eq 'eth-kovan'

      api_get '/api/v2/admin/blockchains', params: { limit: 1, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '3'
      expect(result.size).to eq 1
      expect(result.first['key']).to eq 'eth-rinkeby'
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/blockchains", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/blockchains/new' do
    it 'creates new blockchain' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test'}
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['key']).to eq 'test-blockchain'
    end

    it 'long blockchain key' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: Faker::String.random(1024), name: 'Test', client: 'geth',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test'}
      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.blockchain.key_too_long')
    end

    it 'long blockchain name' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: Faker::String.random(24), name: Faker::String.random(1024), client: 'geth',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test'}
      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.blockchain.name_too_long')
    end

    it 'validate height param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth',server: 'http://127.0.0.1', height: -123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: 6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.non_positive_height')
    end

    it 'validate min_confirmations param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: -6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.non_positive_min_confirmations')
    end

    it 'validate status param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'actived', min_confirmations: 6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.invalid_status')
    end

    it 'validate client param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'gezz',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: 6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.invalid_client')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { }

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.missing_key')
      expect(response).to include_api_error('admin.blockchain.missing_name')
      expect(response).to include_api_error('admin.blockchain.missing_client')
      expect(response).to include_api_error('admin.blockchain.missing_height')
    end

    it 'validates server' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth',server: 'not_a_url', height: 123333, explorer_transaction: 'test', explorer_address: 'test'}

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.invalid_server')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/blockchains/new', token: level_3_member_token, params: { key: 'test-blockchain', name: 'Test', client: 'geth', server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: 6, step: 2 }
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    it 'key already exists' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: Blockchain.first.key, name: 'Test', client: 'geth',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test'}
      expect(response.status).to eq 422
    end
  end

  describe 'POST /api/v2/admin/blockchains/update' do
    it 'returns updated blockchain' do
      api_post '/api/v2/admin/blockchains/update', params: { key: 'test-blockchain', id: Blockchain.first.id }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['key']).to eq 'test-blockchain'
    end

    it 'long blockchain key' do
      api_post '/api/v2/admin/blockchains/update', token: token, params: { key: Faker::String.random(1024) }
      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.blockchain.key_too_long')
    end

    it 'long blockchain name' do
      api_post '/api/v2/admin/blockchains/update', token: token, params: { name: Faker::String.random(1024) }
      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.blockchain.name_too_long')
    end

    it 'validate height param' do
      api_post '/api/v2/admin/blockchains/update', token: token, params: { height: -123333 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.non_positive_height')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/blockchains/update', token: level_3_member_token, params: { key: 'test-blockchain'}
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.missing_id')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/blockchains/update', token: level_3_member_token, params: { id: Blockchain.first.id }
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end
end
