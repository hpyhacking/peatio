# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::WhitelistedSmartContracts, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example15@gmail.com', uid: 'ID73BF61C8H1') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }
  let(:test_file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'resources', 'whitelisted_addresses', file_name), 'text/csv') }
  let(:file_name) { '1.csv' }

  describe 'GET /api/v2/admin/whitelisted_smart_contract/:id' do
    let!(:addresses_1) { create(:whitelisted_smart_contract, :address_1) }
    let!(:addresses_2) { create(:whitelisted_smart_contract, :address_2) }
    let!(:addresses_3) { create(:whitelisted_smart_contract, :address_3) }
    let!(:addresses_4) { create(:whitelisted_smart_contract, :address_4) }
    let!(:addresses_5) { create(:whitelisted_smart_contract, :address_5) }

    let(:whitelisted_address) { WhitelistedSmartContract.find(1) }

    it 'returns information about specified WhitelistedSmartContract' do
      api_get "/api/v2/admin/whitelisted_smart_contract/#{whitelisted_address.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq whitelisted_address.id
      expect(result.fetch('address')).to eq whitelisted_address.address
    end

    it 'returns error in case of invalid id' do
      api_get '/api/v2/admin/whitelisted_smart_contract/120', token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/whitelisted_smart_contract/#{whitelisted_address.id}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'GET /api/v2/admin/whitelisted_smart_contracts' do
    let!(:addresses_1) { create(:whitelisted_smart_contract, :address_1) }
    let!(:addresses_2) { create(:whitelisted_smart_contract, :address_2) }
    let!(:addresses_3) { create(:whitelisted_smart_contract, :address_3) }
    let!(:addresses_4) { create(:whitelisted_smart_contract, :address_4) }
    let!(:addresses_5) { create(:whitelisted_smart_contract, :address_5) }

    it 'lists of whitelisted_smart_contracts' do
      api_get '/api/v2/admin/whitelisted_smart_contracts', token: token

      expect(response).to be_successful
      result = JSON.parse(response.body)
      expect(result.size).to eq WhitelistedSmartContract.count
    end

    it 'returns paginated whitelisted_smart_contracts' do
      api_get '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { limit: 4, page: 1 }
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq WhitelistedSmartContract.count.to_s
      expect(result.size).to eq 4
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/whitelisted_smart_contracts", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    context 'filtering' do
      it 'filters by blockchain key' do
        api_get "/api/v2/admin/whitelisted_smart_contracts", token: token, params: { blockchain_key: "eth-rinkeby" }

        result = JSON.parse(response.body)

        expect(result.length).not_to eq 0
        expect(result.map { |r| r["blockchain_key"]}).to all eq "eth-rinkeby"
      end
    end
  end

  describe 'POST /api/v2/admin/whitelisted_smart_contracts/csv' do
    it 'create whitelisted_smart_contracts from csv' do
      api_post '/api/v2/admin/whitelisted_smart_contracts/csv', token: token, params: { file: test_file }
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 3
    end
  end

  describe 'POST /api/v2/admin/whitelisted_smart_contracts' do
    it 'create whitelisted_smart_contracts' do
      api_post '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { description: 'Test', address: 'blank', blockchain_key: 'eth-rinkeby' }
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['description']).to eq 'Test'
    end

    it 'checked required params' do
      api_post '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { }

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.whitelistedsmartcontract.missing_address')
      expect(response).to include_api_error('admin.whitelistedsmartcontract.missing_blockchain_key')
    end

    it 'validate state' do
      api_post '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { description: 'Test', address: 'blank', blockchain_key: 'eth-rinkeby', state: 'invalid' }

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.whitelistedsmartcontract.invalid_state')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/whitelisted_smart_contracts', params: { description: 'Test', address: 'blank', blockchain_key: 'eth-rinkeby'}, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'PUT /api/v2/admin/whitelisted_smart_contracts' do
    let!(:addresses_1) { create(:whitelisted_smart_contract, :address_1) }

    it 'update WhitelistedSmartContract' do
      api_put '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { id: WhitelistedSmartContract.first.id, address: 'test' }
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['address']).to eq 'test'
    end

    it 'update WhitelistedSmartContract with new description' do
      api_put '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { id: WhitelistedSmartContract.first.id, description: 'test'}
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(WhitelistedSmartContract.first.description).to eq 'test'
    end

    it 'update WhitelistedSmartContract with new state' do
      api_put '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { id: WhitelistedSmartContract.first.id, state: 'disabled' }

      expect(response).to be_successful
      expect(WhitelistedSmartContract.first.state).to eq 'disabled'
    end

    it 'validate blockchain_key' do
      api_put '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { id: WhitelistedSmartContract.first.id, blockchain_key: 'test' }

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.whitelistedsmartcontract.blockchain_key_doesnt_exist')
    end

    it 'validate status' do
      api_put '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { id: WhitelistedSmartContract.first.id, state: 'disable' }

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.whitelistedsmartcontract.invalid_state')
    end

    it 'checked required params' do
      api_put '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { }

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.whitelistedsmartcontract.missing_id')
    end

    it 'return error in case of not permitted ability' do
      api_put '/api/v2/admin/whitelisted_smart_contracts', params: { id: WhitelistedSmartContract.first.id, status: 'disabled' }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    it 'return error in case of not permitted ability' do
      api_put '/api/v2/admin/whitelisted_smart_contracts', params: { id: WhitelistedSmartContract.last.id + 1, status: 'disabled' }, token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    context 'rails validations' do
      let!(:addresses_1) { create(:whitelisted_smart_contract, :address_1) }
      let!(:addresses_2) { create(:whitelisted_smart_contract, :address_2) }

      it 'returns error' do
        api_put '/api/v2/admin/whitelisted_smart_contracts', token: token, params: { id: WhitelistedSmartContract.first.id, address: addresses_2.address }

        expect(response).to include_api_error 'Address has already been taken'
      end
    end
  end
end
