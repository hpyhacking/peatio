# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Currencies, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_currencies: { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] },
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
  end
end
