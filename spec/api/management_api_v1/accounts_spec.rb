# encoding: UTF-8
# frozen_string_literal: true

describe ManagementAPIv1::Deposits, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_accounts:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end

  describe 'get balance' do
    def request
      post_json '/management_api/v1/accounts/balance', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { { uid: member.authentications.sample.uid, currency: 'usd'} }
    let(:signers) { %i[alex jeff] }
    let(:member) { create(:member, :barong) }

    before do
      deposit = create(:deposit_usd, member: member)
      deposit.accept
    end

    it 'returns the correct status code' do
      request
      expect(response).to have_http_status(200)
    end

    it 'contains the correct response data' do
      request
      expect(JSON.parse(response.body)).to include(
        'balance' => member.get_account(data[:currency]).balance.to_formatted_s,
        'locked' => member.get_account(data[:currency]).locked.to_formatted_s
      )
    end
  end
end
