# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Accounts, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_accounts:  { permitted_signers: %i[alex jeff], mandatory_signers: %i[alex] }
      }
  end

  describe 'get balance' do
    def request
      post_json '/api/v2/management/accounts/balance', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { { uid: member.uid, currency: 'usd'} }
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
        'balance' => member.get_account(data[:currency]).balance.to_s,
        'locked' => member.get_account(data[:currency]).locked.to_s
      )
    end
  end

  describe 'get balances' do
    def request
      post_json '/api/v2/management/accounts/balances', multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:data) { { currency: 'usd'} }
    let(:signers) { %i[alex jeff] }
    let!(:members) { create_list(:member, 12, :barong) }
    let!(:deposits) do
      members.each do |member|
        create(:deposit_usd, member: member).accept
      end
    end

    it 'returns the correct status code' do
      request
      expect(response).to have_http_status(200)
    end

    it 'paginates' do
      # balances = Account.pluck(:balance)
      data.merge!(page: 1, limit: 4)
      request
      expect(response).to have_http_status(200)
      # expect(JSON.parse(response.body).map { |x| x.fetch('balance').to_f }).to eq balances[0...4].map(&:to_f)
      data.merge!(page: 3, limit: 4)
      request
      expect(response).to have_http_status(200)
      # expect(JSON.parse(response.body).map { |x| x.fetch('balance').to_f }).to eq balances[8...12].map(&:to_f)
    end

    it 'contains the correct response data' do
      request
      expect(JSON.parse(response.body).map { |x| x.fetch('balance').to_f }).to eq Account.pluck(:balance).map(&:to_f)
    end
  end
end
