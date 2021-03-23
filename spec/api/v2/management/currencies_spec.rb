# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Currencies, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_currencies: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
        write_currencies: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end

  describe 'get currency by code' do
    def request
      post_json "/api/v2/management/currencies/#{currency.code}", multisig_jwt_management_api_v1({ data: {} }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:currency) { Currency.find(:usd) }

    it 'returns currency by code' do
      request
      expect(JSON.parse(response.body).fetch('id')).to eq currency.code
    end

    context 'currency code with dot' do
      let!(:currency) { create(:currency, :xagm_cx) }

      it 'returns currency by code' do
        request
        expect(JSON.parse(response.body).fetch('id')).to eq currency.code
      end
    end
  end

  describe 'create currency' do
    def request
      post_json '/api/v2/management/currencies/create', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { {} }
    let(:signers) { %i[alex jeff] }

    it 'create coin' do
      data.merge!(code: 'test', blockchain_key: 'btc-testnet')
      request
      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['type']).to eq 'coin'
    end

    it 'create token' do
      data.merge!(code: 'test', blockchain_key: 'btc-testnet', parent_id: 'btc')
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['type']).to eq 'coin'
      expect(result['parent_id']).to eq 'btc'
    end

    it 'create fiat' do
      data.merge!(code: 'test', type: 'fiat')
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['type']).to eq 'fiat'
    end

    it 'validate blockchain_key param' do
      data.merge!(code: 'test', blockchain_key: 'test-blockchain')
      request
      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.blockchain_key_doesnt_exist/i)
    end

    it 'validate type param' do
      data.merge!(code: 'test', blockchain_key: 'test-blockchain' , type: 'test')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_type/i)
    end

    it 'validate visible param' do
      data.merge!(code: 'test', type: 'fiat', visible: '123')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.non_boolean_visible/i)
    end

    it 'validate parent_id param' do
      data.merge!(code: 'test', type: 'coin', parent_id: 'trst')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.parent_id_doesnt_exist/i)
    end

    it 'validate deposit_enabled param' do
      data.merge!(code: Currency.first.id, deposit_enabled: '123')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.non_boolean_deposit_enabled/i)
    end

    it 'validate withdrawal_enabled param' do
      data.merge!(code: Currency.first.id, withdrawal_enabled: '123')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.non_boolean_withdrawal_enabled/i)
    end

    it 'validate options param' do
      data.merge!(code: 'test', type: 'fiat', options: 'test')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.non_json_options/i)
    end

    it 'verifies subunits >= 0' do
      data.merge!(code: 'test', blockchain_key: 'btc-testnet', subunits: -1)
      request

      expect(response.body).to match(/management.currency.invalid_subunits/i)
      expect(response).not_to be_successful
    end

    it 'verifies subunits <= 18' do
      data.merge!(code: 'test', blockchain_key: 'btc-testnet', subunits: 19)
      request

      expect(response.body).to match(/management.currency.invalid_subunits/i)
      expect(response).not_to be_successful
    end

    it 'creates 1_000_000_000_000_000_000 base_factor' do
      data.merge!(code: 'test', blockchain_key: 'btc-testnet', subunits: 18)
      request

      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['base_factor']).to eq 1_000_000_000_000_000_000
      expect(result['subunits']).to eq 18
    end

    it 'return error while putting base_factor and subunit params' do
      data.merge!(code: 'test', blockchain_key: 'btc-testnet', subunits: 18, base_factor: 1)
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.currency.one_of_base_factor_subunits_fields/i)
    end

    it 'creates currency with 1000 base_factor' do
      data.merge!(code: 'test', blockchain_key: 'btc-testnet', base_factor: 1000)
      request

      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['base_factor']).to eq 1000
      expect(result['subunits']).to eq 3
    end

    it 'checked required params' do
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/code is missing/i)
    end
  end

  describe 'update currency' do
    def request
      put_json '/api/v2/management/currencies/update', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { {} }
    let(:signers) { %i[alex jeff] }
    let(:currency) { Currency.find(:btc) }

    it 'should validate deposit_fee param' do
      data.merge!(id: currency.id, deposit_fee: -10.0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_deposit_fee/i)
    end

    it 'should validate min_deposit_amount param' do
      data.merge!(id: currency.id, min_deposit_amount: -123.0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_min_deposit_amount/i)
    end

    it 'should validate min_collection_amount param' do
      data.merge!(id: currency.id, min_collection_amount: -100.0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_min_collection_amount/i)
    end

    it 'should validate withdraw_fee param' do
      data.merge!(id: currency.id, withdraw_fee: -100.0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_withdraw_fee/i)
    end

    it 'should validate min_withdraw_amount param' do
      data.merge!(id: currency.id, min_withdraw_amount: -1)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_min_withdraw_amount/i)
    end

    it 'should validate withdraw_limit_24h param' do
      data.merge!(id: currency.id, withdraw_limit_24h: -1)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_withdraw_limit_24h/i)
    end

    it 'should validate withdraw_limit_72h param' do
      data.merge!(id: currency.id, withdraw_limit_72h: -1)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_withdraw_limit_72h/i)
    end

    it 'should validate options param' do
      data.merge!(id: currency.id, options: 'blah-blah')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/non_json_options/i)
    end

    it 'should validate visible param' do
      data.merge!(id: currency.id, visible: 'blah-blah')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.non_boolean_visible/i)
    end

    it 'should validate position param' do
      data.merge!(id: currency.id, position: 0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_position/i)
    end

    it 'should validate deposit_enabled param' do
      data.merge!(id: currency.id, deposit_enabled: 'blah-blah')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.non_boolean_deposit_enabled/i)
    end

    it 'should validate withdrawal_enabled param' do
      data.merge!(id: currency.id, withdrawal_enabled: 'blah-blah')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.non_boolean_withdrawal_enabled/i)
    end

    it 'should check required params' do
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/id is missing/i)
    end

    it 'should update currency' do
      data.merge!(id: currency.id, visible: 'true', withdraw_fee: '0.1')
      request

      expect(response).to have_http_status 200

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq currency.id
      expect(result.fetch('visible')).to eq true
      expect(result.fetch('withdraw_fee')).to eq '0.1'
    end
  end

  describe 'POST /api/v2/management/currencies/list' do
    def request
      post_json "/api/v2/management/currencies/list", multisig_jwt_management_api_v1({ data: data }, *signers)
    end
    let(:signers) { %i[alex jeff] }
    let(:data) { {} }

    it 'lists visible currencies' do
      request
      expect(response).to have_http_status 200

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.count
    end

    it 'lists visible coins' do
      data.merge!(type: 'coin')
      request
      expect(response).to have_http_status 200

      result = JSON.parse(response.body)
      expect(result.size).to eq Currency.coins.size
    end

    it 'lists visible fiats' do
      data.merge!(type: 'fiat')
      request
      expect(response).to have_http_status 200

      result = JSON.parse(response.body, symbolize_names: true)
      expect(result.size).to eq Currency.fiats.size
      expect(result.dig(0, :id)).to eq 'usd'
    end

    it 'returns error in case of invalid type' do
      data.merge!(type: 'invalid')
      request
      expect(response).to have_http_status 422
    end
  end
end
