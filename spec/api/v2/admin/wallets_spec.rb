# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Wallets, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/wallets/:id' do
    let(:wallet) { Wallet.find_by(blockchain_key: 'eth-rinkeby') }

    it 'returns information about specified wallet' do
      api_get "/api/v2/admin/wallets/#{wallet.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq wallet.id
      expect(result.fetch('currency')).to eq wallet.currency_id
      expect(result.fetch('address')).to eq wallet.address
    end

    it 'returns error in case of invalid id' do
      api_get '/api/v2/admin/wallets/120', token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/wallets/#{wallet.id}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    it 'returns information about specified wallet' do
      api_get "/api/v2/admin/wallets/#{wallet.id}", token: token
      expect(response).to be_successful
      result = JSON.parse(response.body)

      expect(result['settings']).not_to include('secret')
    end
  end

  describe 'GET /api/v2/admin/wallets' do
    it 'lists of wallets' do
      api_get '/api/v2/admin/wallets', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq 13
    end

    it 'returns wallets by ascending order' do
      api_get '/api/v2/admin/wallets', params: { ordering: 'asc', order_by: 'currency_id'}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['currency']).to eq 'btc'
    end

    it 'returns paginated wallets' do
      api_get '/api/v2/admin/wallets', params: { limit: 6, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '13'
      expect(result.size).to eq 6
      expect(result.first['name']).to eq 'Ethereum Deposit Wallet'

      api_get '/api/v2/admin/wallets', params: { limit: 6, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '13'
      expect(result.size).to eq 6
      expect(result.first['name']).to eq 'Kovan Ethereum Fee Wallet'
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/wallets", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    context 'filtering' do
      it 'filters by blockchain key' do
        api_get "/api/v2/admin/wallets", token: token, params: { blockchain_key: "eth-rinkeby" }

        result = JSON.parse(response.body)

        expect(result.length).not_to eq 0
        expect(result.map { |r| r["blockchain_key"]}).to all eq "eth-rinkeby"
      end

      it 'filters by kind'do
        api_get "/api/v2/admin/wallets", token: token, params: { kind: "deposit" }

        result = JSON.parse(response.body)

        expect(result.length).not_to eq 0
        expect(result.map { |r| r["kind"]}).to all eq "deposit"
      end

      it 'filters by currency'do
        api_get "/api/v2/admin/wallets", token: token, params: { currency: "eth" }

        result = JSON.parse(response.body)

        expect(result.length).not_to eq 0
        expect(result.map { |r| r["currency"]}).to all eq "eth"
      end
    end
  end

  describe 'GET /api/v2/admin/wallets/kinds' do
    it 'list kinds' do
      api_get '/api/v2/admin/wallets/kinds', token: token
      expect(response).to be_successful
    end
  end

  describe 'GET /api/v2/admin/wallets/gateways' do
    it 'list gateways' do
      api_get '/api/v2/admin/wallets/gateways', token: token
      expect(response).to be_successful
    end
  end

  describe 'POST /api/v2/admin/wallets/new' do
    it 'create wallet' do
      api_post '/api/v2/admin/wallets/new', params: { name: 'Test', kind: 'deposit', currency: 'eth', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', settings: { uri: 'http://127.0.0.1:18332'}}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['name']).to eq 'Test'
    end

    it 'checked required params' do
      api_post '/api/v2/admin/wallets/new', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.wallet.missing_name')
      expect(response).to include_api_error('admin.wallet.missing_kind')
      expect(response).to include_api_error('admin.wallet.missing_currency')
      expect(response).to include_api_error('admin.wallet.missing_address')
      expect(response).to include_api_error('admin.wallet.missing_blockchain_key')
      expect(response).to include_api_error('admin.wallet.missing_gateway')
    end

    it 'validate status' do
      api_post '/api/v2/admin/wallets/new', params: { name: 'Test', kind: 'deposit', currency: 'eth', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', settings: { uri: 'http://127.0.0.1:18332'}, status: 'disable' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.invalid_status')
    end

    it 'validate gateway' do
      api_post '/api/v2/admin/wallets/update', params: { name: 'Test', kind: 'deposit', currency: 'eth', address: 'blank', blockchain_key: 'btc-testnet', settings: { uri: 'http://127.0.0.1:18332'}, gateway: 'test' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.gateway_doesnt_exist')
    end

    it 'validate kind' do
      api_post '/api/v2/admin/wallets/update', params: { name: 'Test', kind: 'test', currency: 'eth', address: 'blank', blockchain_key: 'btc-testnet', settings: { uri: 'http://127.0.0.1:18332'}, gateway: 'geth' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.invalid_kind')
    end

    it 'validate currency_id' do
      api_post '/api/v2/admin/wallets/update', params: { id: 1, name: 'Test', kind: 'deposit', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', settings: { uri: 'http://127.0.0.1:18332'}, currency: 'test' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.currency_doesnt_exist')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/wallets/new', params: { name: 'Test', kind: 'deposit', currency: 'eth', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', settings: { uri: 'http://127.0.0.1:18332'}}, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/wallets/update' do
    it 'update wallet' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, gateway: 'geth' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['gateway']).to eq 'geth'
    end

    it 'update currency' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, currency: 'btc' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currency']).to eq 'btc'
    end

    it 'validate blockchain_key' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, blockchain_key: 'test' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.blockchain_key_doesnt_exist')
    end

    it 'validate status' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, status: 'disable' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.invalid_status')
    end

    it 'validate gateway' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, gateway: 'test' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.gateway_doesnt_exist')
    end

    it 'validate kind' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, kind: 'test' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.invalid_kind')
    end

    it 'validate currency_id' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, currency: 'test ' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.currency_doesnt_exist')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/wallets/update', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.wallet.missing_id')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, status: 'disabled' }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end
end
