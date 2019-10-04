# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Markets, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        write_markets: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
      }
  end

  describe 'update market' do
    def request
      put_json '/api/v2/management/markets/update', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { {} }
    let(:signers) { %i[alex jeff] }
    let(:market) { Market.find(:btcusd) }

    it 'should validate min_price param' do
      data.merge!(id: market.id, min_price: -10.0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/min_price does not have a valid value/i)
    end

    it 'should validate min_amount param' do
      data.merge!(id: market.id, min_amount: -123.0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/min_amount does not have a valid value/i)
    end

    it 'should validate amount_precision param' do
      data.merge!(id: market.id, amount_precision: -100.0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/amount_precision does not have a valid value/i)
    end

    it 'should validate price_precision param' do
      data.merge!(id: market.id, price_precision: -100.0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/price_precision does not have a valid value/i)
    end

    it 'should validate max_price param' do
      data.merge!(id: market.id, max_price: -1)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/max_price does not have a valid value/i)
    end

    it 'should validate position param' do
      data.merge!(id: market.id, position: -100.0)
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/position must be greater than or equal to 0/i)
    end

    it 'should validate state param' do
      data.merge!(id: market.id, state: 'blah-blah')
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/state does not have a valid value/i)
    end

    it 'should check required params' do
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/id is missing/i)
    end

    it 'should update market' do
      data.merge!(id: market.id, state: 'disabled', min_amount: 0.1)
      request

      expect(response).to have_http_status 200

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq market.id
      expect(result.fetch('state')).to eq 'disabled'
      expect(result.fetch('min_amount')).to eq '0.1'
    end
  end
end
