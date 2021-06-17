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
      data.merge!(code: 'test')
      request
      result = JSON.parse(response.body)
      expect(response).to be_successful
      expect(result['type']).to eq 'coin'
    end

    it 'create fiat' do
      data.merge!(code: 'test', type: 'fiat')
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['type']).to eq 'fiat'
    end

    it 'validate type param' do
      data.merge!(code: 'test', blockchain_key: 'test-blockchain' , type: 'test')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_type/i)
    end

    it 'validate status param' do
      data.merge!(code: 'test', type: 'fiat', status: '123')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_status/i)
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


    it 'should validate status param' do
      data.merge!(id: currency.id, status: 'blah-blah')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_status/i)
    end

    it 'should validate position param' do
      data.merge!(id: currency.id, position: 0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/management.currency.invalid_position/i)
    end

    it 'should check required params' do
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/id is missing/i)
    end

    it 'should update currency' do
      data.merge!(id: currency.id, status: 'enabled')
      request

      expect(response).to have_http_status 200

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq currency.id
      expect(result.fetch('status')).to eq 'enabled'
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
