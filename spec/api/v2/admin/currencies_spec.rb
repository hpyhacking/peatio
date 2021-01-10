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

    let(:expected_for_fiat) do
      %w[code type deposit_fee withdraw_fee withdraw_limit_24h withdraw_limit_72h min_collection_amount base_factor precision position]
    end
    let(:expected_for_coin) do
      expected_for_fiat.concat(%w[blockchain_key base_factor precision subunits options])
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
      expected_for_fiat.each { |key| expect(result).to have_key key }

      (expected_for_coin - expected_for_fiat).each do |key|
        expect(result).not_to have_key key
      end
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
      expected_for_coin.each { |key| expect(result).to have_key key }
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

    it 'list of deposit enabled currencies' do
      api_get '/api/v2/admin/currencies', params: { deposit_enabled: true }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.deposit_enabled.count
    end

    it 'list of deposit disabled currencies' do
      api_get '/api/v2/admin/currencies', params: { deposit_enabled: false }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.where(deposit_enabled: false).count
    end

    it 'returns error in case of invalid deposit_enabled type' do
      api_get '/api/v2/admin/currencies', params: { deposit_enabled: 'invalid' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_deposit_enabled')
    end

    it 'list of withdrawal enabled currencies' do
      api_get '/api/v2/admin/currencies', params: { withdrawal_enabled: true }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.withdrawal_enabled.count
    end

    it 'list of withdrawal disabled currencies' do
      api_get '/api/v2/admin/currencies', params: { withdrawal_enabled: false }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.where(withdrawal_enabled: false).count
    end

    it 'returns error in case of invalid withdrawal_enabled type' do
      api_get '/api/v2/admin/currencies', params: { withdrawal_enabled: 'invalid' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_withdrawal_enabled')
    end

    it 'list of visible currencies' do
      api_get '/api/v2/admin/currencies', params: { visible: true }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.visible.count
    end

    it 'list of not visible currencies' do
      api_get '/api/v2/admin/currencies', params: { visible: false }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.where(visible: false).count
    end

    it 'returns error in case of invalid visible type' do
      api_get '/api/v2/admin/currencies', params: { visible: 'invalid' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_visible')
    end

    it 'list of visible coins' do
      api_get '/api/v2/admin/currencies', params: { visible: true, type: 'coin' }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.coins.select { |c| c['visible'] == true }.count
    end

    it 'list of not visible coins' do
      api_get '/api/v2/admin/currencies', params: { visible: false, type: 'coin' }, token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.coins.where(visible: false).count
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
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', blockchain_key: 'btc-testnet' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['type']).to eq 'coin'
    end

    it 'create token' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', blockchain_key: 'btc-testnet', parent_id: 'btc' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['type']).to eq 'coin'
      expect(result['parent_id']).to eq 'btc'
    end

    it 'create fiat' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', type: 'fiat' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['type']).to eq 'fiat'
    end

    it 'validate blockchain_key param' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', blockchain_key: 'test-blockchain' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.blockchain_key_doesnt_exist')
    end

    it 'validate type param' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', blockchain_key: 'test-blockchain' , type: 'test'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.invalid_type')
    end

    it 'validate visible param' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', type: 'fiat', visible: '123'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_visible')
    end

    it 'validate parent_id param' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', type: 'coin', parent_id: 'trst'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.parent_id_doesnt_exist')
    end

    it 'validate deposit_enabled param' do
      api_post '/api/v2/admin/currencies/new', params: { code: Currency.first.id, deposit_enabled: '123' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_deposit_enabled')
    end

    it 'validate withdrawal_enabled param' do
      api_post '/api/v2/admin/currencies/new', params: { code: Currency.first.id, withdrawal_enabled: '123' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_withdrawal_enabled')
    end

    it 'validate options param' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', type: 'fiat', options: 'test'}, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_json_options')
    end

    it 'verifies subunits >= 0' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', blockchain_key: 'btc-testnet', subunits: -1 }, token: token

      expect(response).to include_api_error 'admin.currency.invalid_subunits'
      expect(response).not_to be_successful
    end

    it 'verifies subunits <= 18' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', blockchain_key: 'btc-testnet', subunits: 19 }, token: token

      expect(response).to include_api_error 'admin.currency.invalid_subunits'
      expect(response).not_to be_successful
    end

    it 'creates 1_000_000_000_000_000_000 base_factor' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', blockchain_key: 'btc-testnet', subunits: 18 }, token: token

      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['base_factor']).to eq 1_000_000_000_000_000_000
      expect(result['subunits']).to eq 18
    end

    it 'return error while putting base_factor and subunit params' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', blockchain_key: 'btc-testnet', subunits: 18, base_factor: 1 }, token: token

      result = JSON.parse(response.body)

      expect(response.code).to eq '422'
      expect(result['errors']).to eq(['admin.currency.one_of_base_factor_subunits_fields'])
    end

    it 'creates currency with 1000 base_factor' do
      api_post '/api/v2/admin/currencies/new', params: { code: 'test', blockchain_key: 'btc-testnet', base_factor: 1000 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['base_factor']).to eq 1000
      expect(result['subunits']).to eq 3
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
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.find_by(type: 'fiat').code, min_collection_amount: 1.2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['min_collection_amount']).to eq '1.2'
    end

    it 'update coin' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.find_by(type: 'coin').code, min_collection_amount: 1.2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['min_collection_amount']).to eq '1.2'
    end

    it 'validate blockchain_key param' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.find_by(type: 'coin').code, blockchain_key: 'test' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.blockchain_key_doesnt_exist')
    end

    it 'validate parent_id param' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.find_by(type: 'coin').code, parent_id: 'trst' }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.parent_id_doesnt_exist')
    end

    it 'validate position param' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.find_by(type: 'coin').code, position: 0 }, token: token
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.invalid_position')
    end

    it 'validate visible param' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.first.id, visible: '123' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_visible')
    end

    it 'validate deposit_enabled param' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.first.id, deposit_enabled: '123' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_deposit_enabled')
    end

    it 'validate withdrawal_enabled param' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.first.id, withdrawal_enabled: '123' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_boolean_withdrawal_enabled')
    end

    it 'validates negative precision' do
      expect {
        api_post '/api/v2/admin/currencies/update', params: { code: Currency.first.id, precision: -1 }, token: token
      }.not_to change { Currency.first }

      expect(response).not_to be_successful
      expect(response.status).to eq 422
    end

    it 'validate options param' do
      api_post '/api/v2/admin/currencies/update', params: { code: Currency.first.id, options: 'test' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.currency.non_json_options')
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
