# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Account::Deposits, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:other_member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:level_0_member) { create(:member, :level_0) }
  let(:level_0_member_token) { jwt_for(level_0_member) }

  describe 'GET /api/v2/account/deposits' do
    before do
      create(:deposit_btc, member: member)
      create(:deposit_usd, member: member)
      create(:deposit_usd, member: member, txid: 1, amount: 520)
      create(:deposit_btc, member: member, created_at: 2.day.ago, txid: 'test', amount: 111)
      create(:deposit_usd, member: other_member, txid: 10)
    end

    it 'requires authentication' do
      api_get '/api/v2/account/deposits'
      expect(response.code).to eq '401'
    end

    it 'returns with auth token deposits' do
      api_get '/api/v2/account/deposits', token: token
      expect(response).to be_successful
    end

    it 'returns all deposits num' do
      api_get '/api/v2/account/deposits', token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 4

      expect(response.headers.fetch('Total')).to eq '4'
    end

    it 'returns limited deposits' do
      api_get '/api/v2/account/deposits', params: { limit: 2, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 2
      expect(response.headers.fetch('Total')).to eq '4'

      api_get '/api/v2/account/deposits', params: { limit: 1, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 1
      expect(response.headers.fetch('Total')).to eq '4'
    end

    it 'filters deposits by state' do
      api_get '/api/v2/account/deposits', params: { state: 'canceled' }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 0

      d = create(:deposit_btc, member: member, aasm_state: :canceled)
      api_get '/api/v2/account/deposits', params: { state: 'canceled' }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 1
      expect(result.first['txid']).to eq d.txid
    end

    it 'filters deposits by multiple states' do
      create(:deposit_btc, member: member, aasm_state: :rejected)
      api_get '/api/v2/account/deposits', params: { state: ['canceled', 'rejected'] }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 1

      create(:deposit_btc, member: member, aasm_state: :canceled)
      api_get '/api/v2/account/deposits', params: { state: ['canceled', 'rejected'] }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 2
    end

    it 'returns deposits for currency usd' do
      api_get '/api/v2/account/deposits', params: { currency: 'usd' }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 2
      expect(result.all? { |d| d['currency'] == 'usd' }).to be_truthy
    end

    it 'returns deposits with txid filter' do
      api_get '/api/v2/account/deposits', params: { txid: Deposit.first.txid }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 1
      expect(result.all? { |d| d['txid'] == Deposit.first.txid }).to be_truthy
    end

    it 'returns deposits for currency btc' do
      api_get '/api/v2/account/deposits', params: { currency: 'btc' }, token: token
      result = JSON.parse(response.body)

      expect(response.headers.fetch('Total')).to eq '2'
      expect(result.all? { |d| d['currency'] == 'btc' }).to be_truthy
    end

    it 'return 404 if txid not exist' do
      api_get '/api/v2/account/deposits/5', token: token
      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'returns 404 if txid not belongs_to you ' do
      api_get '/api/v2/account/deposits/10', token: token
      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'returns deposit txid if exist' do
      api_get '/api/v2/account/deposits/1', token: token
      result = JSON.parse(response.body)

      expect(response.code).to eq '200'
      expect(result['amount']).to eq '520.0'
    end

    it 'returns deposit no time limit ' do
      api_get '/api/v2/account/deposits/test', token: token
      result = JSON.parse(response.body)

      expect(response.code).to eq '200'
      expect(result['amount']).to eq '111.0'
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/account/deposits', token: level_0_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('account.deposit.not_permitted')
    end
  end

  describe 'GET /api/v2/account/deposit_address/:currency' do
    let(:currency) { :bch }

    context 'failed' do
      it 'validates currency' do
        api_get "/api/v2/account/deposit_address/dildocoin", token: token
        expect(response).to have_http_status 422
        expect(response).to include_api_error('account.currency.doesnt_exist')
      end

      it 'validates currency address format' do
        api_get '/api/v2/account/deposit_address/btc', params: { address_format: 'cash' }, token: token
        expect(response).to have_http_status 422
        expect(response).to include_api_error('account.deposit_address.doesnt_support_cash_address_format')
      end

      it 'validates currency with address_format param' do
        api_get '/api/v2/account/deposit_address/abc', params: { address_format: 'cash' }, token: token
        expect(response).to have_http_status 422
        expect(response).to include_api_error('account.currency.doesnt_exist')
      end
    end

    context 'successful' do
      context 'eth address' do
        let(:currency) { :eth }
        let(:wallet) { Wallet.joins(:currencies).find_by(currencies: { id: currency }) }
        before { member.payment_address(wallet.id).update!(address: '2N2wNXrdo4oEngp498XGnGCbru29MycHogR') }

        it 'expose data about eth address' do
          api_get "/api/v2/account/deposit_address/#{currency}", token: token
          expect(response.body).to eq '{"currencies":["eth"],"address":"2n2wnxrdo4oengp498xgngcbru29mychogr","state":"active"}'
        end

        it 'pending user address state' do
          member.payment_address(wallet.id).update!(address: nil)
          api_get "/api/v2/account/deposit_address/#{currency}", token: token
          expect(response.body).to eq '{"currencies":["eth"],"address":null,"state":"pending"}'
        end
      end

      xit 'doesn\'t expose sensitive data' do
        api_get "/api/v2/account/deposit_address/#{currency}", token: token
        expect(response.body).to eq '{"currency":"bch","address":"bchtest:pp49pee25hv4esy7ercslnvnvxqvk5gjdv5a06mg35","state": "active"}'
      end

      xit 'return cash address' do
        api_get "/api/v2/account/deposit_address/#{currency}", params: { address_format: 'cash'}, token: token
        expect(response.body).to eq '{"currency":"bch","address":"bchtest:pp49pee25hv4esy7ercslnvnvxqvk5gjdv5a06mg35","state": "active"}'
      end

      xit 'return legacy address' do
        api_get "/api/v2/account/deposit_address/#{currency}", params: { address_format: 'legacy'}, token: token
        expect(response.body).to eq '{"currency":"bch","address":"2N2wNXrdo4oEngp498XGnGCbru29MycHogR","state": "active"}'
      end
    end

    context 'disabled deposit for currency' do
      let(:currency) { :btc }

      before { Currency.find(currency).update!(deposit_enabled: false) }

      it 'returns error' do
        api_get "/api/v2/account/deposit_address/#{currency}", token: token
        expect(response).to have_http_status 422
        expect(response).to include_api_error('account.currency.deposit_disabled')
      end
    end
  end
end
