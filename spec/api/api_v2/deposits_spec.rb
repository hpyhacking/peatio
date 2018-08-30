# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Deposits, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:other_member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:level_0_member) { create(:member, :level_0) }
  let(:level_0_member_token) { jwt_for(level_0_member) }

  describe 'GET /api/v2/deposits' do
    before do
      create(:deposit_btc, member: member)
      create(:deposit_usd, member: member)
      create(:deposit_usd, member: member, txid: 1, amount: 520)
      create(:deposit_btc, member: member, created_at: 2.day.ago, txid: 'test', amount: 111)
      create(:deposit_usd, member: other_member, txid: 10)
    end

    it 'require deposits authentication' do
      api_get '/api/v2/deposits'
      expect(response.code).to eq '401'
    end

    it 'login deposits' do
      api_get '/api/v2/deposits', token: token
      expect(response).to be_success
    end

    it 'deposits num' do
      api_get '/api/v2/deposits', token: token
      expect(JSON.parse(response.body).size).to eq 3
    end

    it 'return limited deposits' do
      api_get '/api/v2/deposits', params: { limit: 1 }, token: token
      expect(JSON.parse(response.body).size).to eq 1
    end

    it 'filter deposits by state' do
      api_get '/api/v2/deposits', params: { state: 'canceled' }, token: token
      expect(JSON.parse(response.body).size).to eq 0

      d = create(:deposit_btc, member: member, aasm_state: :canceled)
      api_get '/api/v2/deposits', params: { state: 'canceled' }, token: token
      json = JSON.parse(response.body)
      expect(json.size).to eq 1
      expect(json.first['txid']).to eq d.txid
    end

    it 'deposits currency usd' do
      api_get '/api/v2/deposits', params: { currency: 'usd' }, token: token
      result = JSON.parse(response.body)
      expect(result.size).to eq 2
      expect(result.all? { |d| d['currency'] == 'usd' }).to be_truthy
    end

    it 'return 404 if txid not exist' do
      api_get '/api/v2/deposit', params: { txid: 5 }, token: token
      expect(response.code).to eq '404'
    end

    it 'return 404 if txid not belongs_to you ' do
      api_get '/api/v2/deposit', params: { txid: 10 }, token: token
      expect(response.code).to eq '404'
    end

    it 'ok txid if exist' do
      api_get '/api/v2/deposit', params: { txid: 1 }, token: token

      expect(response.code).to eq '200'
      expect(JSON.parse(response.body)['amount']).to eq '520.0'
    end

    it 'return deposit no time limit ' do
      api_get '/api/v2/deposit', params: { txid: 'test' }, token: token

      expect(response.code).to eq '200'
      expect(JSON.parse(response.body)['amount']).to eq '111.0'
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/deposits', token: level_0_member_token
      expect(response.code).to eq '401'
      expect(JSON.parse(response.body)['error']).to eq( {'code' => 2000, 'message' => 'Please, pass the corresponding verification steps to deposit funds.'} )
    end
  end

  describe 'GET /api/v2/deposit_address' do

    context 'failed' do
      it 'validates currency' do
        api_get '/api/v2/deposit_address', params: { currency: :usd }, token: token
        expect(response).to have_http_status 422
        expect(response.body).to eq '{"error":{"code":1001,"message":"currency does not have a valid value"}}'
      end

      it 'validates currency address format' do
        api_get '/api/v2/deposit_address', params: { currency: :btc, address_format: 'cash' }, token: token
        expect(response).to have_http_status 422
        expect(response.body).to eq '{"error":{"code":1001,"message":"currency does not support cash address format."}}'
      end

      it 'validates currency with address_format param' do
        api_get '/api/v2/deposit_address', params: { currency: :abc, address_format: 'cash' }, token: token
        expect(response).to have_http_status 422
        expect(response.body).to eq '{"error":{"code":1001,"message":"currency does not have a valid value, currency does not support cash address format."}}'
      end
    end

    context 'successful' do
      before { member.ac(:bch).payment_address.update!(address: '2N2wNXrdo4oEngp498XGnGCbru29MycHogR') }

      it 'doesn\'t expose sensitive data' do
        api_get '/api/v2/deposit_address', params: { currency: :bch }, token: token
        expect(response.body).to eq '{"currency":"bch","address":"bchtest:pp49pee25hv4esy7ercslnvnvxqvk5gjdv5a06mg35"}'
      end

      it 'return cash address' do
        api_get '/api/v2/deposit_address', params: { currency: :bch, address_format: 'cash'}, token: token
        expect(response.body).to eq '{"currency":"bch","address":"bchtest:pp49pee25hv4esy7ercslnvnvxqvk5gjdv5a06mg35"}'
      end

      it 'return legacy address' do
        api_get '/api/v2/deposit_address', params: { currency: :bch, address_format: 'legacy'}, token: token
        expect(response.body).to eq '{"currency":"bch","address":"2N2wNXrdo4oEngp498XGnGCbru29MycHogR"}'
      end
    end
  end
end
