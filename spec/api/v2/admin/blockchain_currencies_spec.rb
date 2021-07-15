# frozen_string_literal: true

describe API::V2::Admin::BlockchainCurrencies, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

	describe 'GET blockchain_currencies' do
		it 'list of blockchain currencies' do
      api_get '/api/v2/admin/blockchain_currencies', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.count
    end

		it 'list of deposit enabled blockchain currencies' do
      api_get '/api/v2/admin/blockchain_currencies', params: { deposit_enabled: true }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.deposit_enabled.count
    end

    it 'list of deposit disabled blockchain currencies' do
      api_get '/api/v2/admin/blockchain_currencies', params: { deposit_enabled: false }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.where(deposit_enabled: false).count
    end

    it 'returns error in case of invalid deposit_enabled type' do
      api_get '/api/v2/admin/blockchain_currencies', params: { deposit_enabled: 'invalid' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.non_boolean_deposit_enabled')
    end

		it 'list of withdrawal enabled blockchain currencies' do
      api_get '/api/v2/admin/blockchain_currencies', params: { withdrawal_enabled: true }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.withdrawal_enabled.count
    end

    it 'list of withdrawal disabled blockchain currencies' do
      api_get '/api/v2/admin/blockchain_currencies', params: { withdrawal_enabled: false }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.where(withdrawal_enabled: false).count
    end

		it 'returns error in case of invalid withdrawal_enabled type' do
      api_get '/api/v2/admin/blockchain_currencies', params: { withdrawal_enabled: 'invalid' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.non_boolean_withdrawal_enabled')
    end

    it 'list of enabled blockchain currencies' do
      api_get '/api/v2/admin/blockchain_currencies', params: { status: :enabled }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.where(status: :enabled).count
    end

    it 'list of disabled blockchain currencies' do
      api_get '/api/v2/admin/blockchain_currencies', params: { status: :disabled }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq BlockchainCurrency.where(status: :disabled).count
    end

		it 'returns error in case of invalid status type' do
      api_get '/api/v2/admin/blockchain_currencies', params: { status: 'invalid' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.invalid_status')
    end

    it 'returns blockchain currencies by ascending order' do
      api_get '/api/v2/admin/blockchain_currencies', params: { ordering: 'asc', order_by: 'currency_id'}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['currency_id']).to eq 'btc'
    end

		it 'returns paginated blockchain currencies' do
      api_get '/api/v2/admin/blockchain_currencies', params: { limit: 3, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '6'
      expect(result.size).to eq 3
      expect(result.first['currency_id']).to eq 'ring'

      api_get '/api/v2/admin/blockchain_currencies', params: { limit: 3, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '6'
      expect(result.size).to eq 3
      expect(result.first['currency_id']).to eq 'btc'
    end

    it 'return error in case of not permitted ability' do
      api_get '/api/v2/admin/blockchain_currencies', token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
	end

	describe 'GET blockchain_currencies/:id' do
		let(:blockchain_currency) { BlockchainCurrency.find_by(blockchain_key: 'eth-rinkeby') }

    it 'returns information about specified blockchain currency' do
      api_get "/api/v2/admin/blockchain_currencies/#{blockchain_currency.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result['id']).to eq blockchain_currency.id
			expect(result['deposit_enabled']).to eq blockchain_currency.deposit_enabled
			expect(result['withdrawal_enabled']).to eq blockchain_currency.withdrawal_enabled
      expect(result['auto_update_fees_enabled']).to eq blockchain_currency.auto_update_fees_enabled
			expect(result['deposit_fee']).to eq blockchain_currency.deposit_fee.to_s
			expect(result['min_deposit_amount']).to eq blockchain_currency.min_deposit_amount.to_s
			expect(result['withdraw_fee']).to eq blockchain_currency.withdraw_fee.to_s
			expect(result['min_withdraw_amount']).to eq blockchain_currency.min_withdraw_amount.to_s
			expect(result['base_factor']).to eq blockchain_currency.base_factor
			expect(result['status']).to eq blockchain_currency.status
			expect(result['min_collection_amount']).to eq blockchain_currency.min_collection_amount.to_s
			expect(result['options']).to eq blockchain_currency.options
			expect(result['currency_id']).to eq blockchain_currency.currency_id
			expect(result['blockchain_key']).to eq blockchain_currency.blockchain_key
    end

    it 'returns error in case of invalid id' do
      api_get '/api/v2/admin/blockchain_currencies/0', token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

		it 'return error in case of not permitted ability' do
      api_get '/api/v2/admin/blockchain_currencies/1', token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
	end

	describe 'POST blockchain_currencies/new' do
		it 'create blockchain currency' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', blockchain_key: 'btc-testnet', protocol: 'BTC_T', auto_update_fees_enabled: false }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currency_id']).to eq 'eth'
			expect(result['blockchain_key']).to eq 'btc-testnet'
      expect(result['auto_update_fees_enabled']).to eq false
    end

    it 'create blockchain currency with parent_id' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'trst', parent_id: 'eth', blockchain_key: 'btc-testnet', protocol: 'BTC_T', auto_update_fees_enabled: false }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currency_id']).to eq 'trst'
      expect(result['parent_id']).to eq 'eth'
			expect(result['blockchain_key']).to eq 'btc-testnet'
      expect(result['auto_update_fees_enabled']).to eq false
    end

    it 'validate parent_id param' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'trst', blockchain_key: 'btc-testnet', parent_id: 'eur'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.parent_id_doesnt_exist')
    end

		it 'validate blockchain_key param' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', blockchain_key: 'test' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.blockchain_key_doesnt_exist')
    end

		it 'validate visible param' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', blockchain_key: 'btc-testnet', status: '123'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.invalid_status')
    end

		it 'validate deposit_enabled param' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', blockchain_key: 'btc-testnet', deposit_enabled: '123' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.non_boolean_deposit_enabled')
    end

    it 'validate withdrawal_enabled param' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', blockchain_key: 'btc-testnet', withdrawal_enabled: '123' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.non_boolean_withdrawal_enabled')
    end

		it 'validate options param' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', blockchain_key: 'btc-testnet', options: 'test'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.non_json_options')
    end

    it 'verifies subunits >= 0' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', blockchain_key: 'btc-testnet', subunits: -1 }, token: token

      expect(response).to include_api_error 'admin.blockchain_currency.invalid_subunits'
      expect(response).not_to be_successful
    end

    it 'verifies subunits <= 18' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', blockchain_key: 'btc-testnet', subunits: 19 }, token: token

      expect(response).to include_api_error 'admin.blockchain_currency.invalid_subunits'
      expect(response).not_to be_successful
    end

    it 'creates 1_000_000_000_000_000_000 base_factor' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', blockchain_key: 'btc-testnet', subunits: 18 }, token: token

      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['base_factor']).to eq 1_000_000_000_000_000_000
      expect(result['subunits']).to eq 18
    end

		it 'return error while putting base_factor and subunit params' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', blockchain_key: 'btc-testnet', subunits: 18, base_factor: 1 }, token: token

      result = JSON.parse(response.body)

      expect(response.code).to eq '422'
      expect(result['errors']).to eq(['admin.blockchain_currency.one_of_base_factor_subunits_fields'])
    end

    it 'creates currency with 1000 base_factor' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eth', protocol: 'ERC20', blockchain_key: 'btc-testnet', base_factor: 1000 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['base_factor']).to eq 1000
      expect(result['subunits']).to eq 3
    end

		it 'checked required params' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchaincurrency.missing_currency_id')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/blockchain_currencies/new', params: { currency_id: 'eur', protocol: 'ERC20', blockchain_key: 'btc-testnet' }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
	end

	describe 'POST blockchain_currencies/update' do
    it 'updates blockchain currency' do
      api_post '/api/v2/admin/blockchain_currencies/update', params: { id: BlockchainCurrency.first.id, auto_update_fees_enabled: false }, token: token
      result = JSON.parse(response.body)
      expect(response).to have_http_status 201
      expect(result['auto_update_fees_enabled']).to eq false
    end

		it 'validate status param' do
      api_post '/api/v2/admin/blockchain_currencies/update', params: { id: BlockchainCurrency.first.id, status: 'test' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.invalid_status')
    end

		it 'validate deposit_enabled param' do
      api_post '/api/v2/admin/blockchain_currencies/update', params: { id: BlockchainCurrency.first.id, deposit_enabled: '123' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.non_boolean_deposit_enabled')
    end

    it 'validate withdrawal_enabled param' do
      api_post '/api/v2/admin/blockchain_currencies/update', params: { id: BlockchainCurrency.first.id, withdrawal_enabled: '123' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.non_boolean_withdrawal_enabled')
    end

		it 'validate options param' do
      api_post '/api/v2/admin/blockchain_currencies/update', params: { id: BlockchainCurrency.first.id, options: 'test' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain_currency.non_json_options')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/blockchain_currencies/update', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchaincurrency.missing_id')
    end

		it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/blockchain_currencies/update', params: { id: BlockchainCurrency.first.id, position: 1 }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
	end

  describe 'DELETE blockchain_currencies/:id' do
    context 'successful response' do
      let(:blockchain_currency) { BlockchainCurrency.find_by(blockchain_key: 'eth-rinkeby') }

      it 'return destroyed blockchain_currency' do
        api_delete "/api/v2/admin/blockchain_currencies/#{blockchain_currency.id}", token: token

        expect(response).to be_successful
        result = JSON.parse(response.body)
        expect(result['id']).to eq blockchain_currency.id
        expect(result['currency_id']).to eq blockchain_currency.currency_id
        expect(result['blockchain_key']).to eq blockchain_currency.blockchain_key
      end
    end

    context 'unsuccessful response' do

      it 'return error in case of not permitted ability' do
        api_delete '/api/v2/admin/blockchain_currencies/0', token: token

        expect(response.code).to eq '404'
        expect(response).to include_api_error('record.not_found')
      end

      it 'return error in case of not permitted ability' do
        api_delete '/api/v2/admin/blockchain_currencies/1', token: level_3_member_token

        expect(response.code).to eq '403'
        expect(response).to include_api_error('admin.ability.not_permitted')
      end
    end
  end
end
