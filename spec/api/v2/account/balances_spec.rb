# frozen_string_literal: true

describe API::V2::Account::Balances, type: :request do

  let(:member) { create(:member, :level_3) }
  let(:deposit_btc) { create(:deposit, :deposit_btc, member: member, amount: 10) }
  let(:deposit_eth) { create(:deposit, :deposit_eth, member: member, amount: 30.5) }
  let(:withdraw) { create(:btc_withdraw, member: member, sum: 5) }
  let(:token) { jwt_for(member) }

  let(:response_body) { { 'currency' => 'eth', 'balance' => '30.5', 'locked' => '0.0', 'account_type' => 'spot', 'deposit_address' => nil, 'deposit_addresses' => [] } }

  before do
    Ability.stubs(:user_permissions).returns({'member'=>{'read'=>['Operations::Account']}})
  end

  before do
    deposit_btc.accept!
    deposit_btc.process!
    deposit_btc.dispatch
    deposit_eth.accept!
    deposit_eth.process!
    deposit_eth.dispatch
    withdraw.accept!
  end

  describe 'GET api/v2/account/balances' do

    before do
      member.get_account('usd')
      member.get_account('eth')
      member.get_account('trst')
      member.get_account('ring')
      member.get_account('eur')
      Currency.find(:eur).update!(status: :enabled)
    end

    context 'all balances' do
      before { api_get '/api/v2/account/balances', token: token }


      it 'returns current user balances' do
        expect(response).to have_http_status 200
        result = JSON.parse(response.body)
        expect(result).to contain_exactly(
                              { 'currency' => 'btc', 'balance' => '5.0', 'locked' => '5.0', 'account_type' => 'spot', 'deposit_address' => nil, 'deposit_addresses' => [] },
                              { 'currency' => 'eth', 'balance' => '30.5', 'locked' => '0.0', 'account_type' => 'spot',  'deposit_address' => nil, 'deposit_addresses' => [] },
                              { 'currency' => 'usd', 'balance' => '0.0', 'locked' => '0.0', 'account_type' => 'spot' },
                              { 'currency' => 'trst', 'balance' => '0.0', 'locked' => '0.0', 'account_type' => 'spot', 'deposit_address' => nil, 'deposit_addresses' => [] },
                              { 'currency' => 'ring', 'balance' => '0.0', 'locked' => '0.0', 'account_type' => 'spot', 'deposit_address' => nil, 'deposit_addresses' => [] },
                              { 'currency' => 'eur', 'balance' => '0.0', 'locked' => '0.0', 'account_type' => 'spot' }
                              )
      end

      context 'user with nil email' do
        let!(:member) { create(:member, :level_3, email: 'mail@gmail.com') }
        let!(:deposit_btc) { create(:deposit, :deposit_btc, member: member, amount: 10) }
        let!(:deposit_eth) { create(:deposit, :deposit_eth, member: member, amount: 30.5) }
        let!(:withdraw) { create(:btc_withdraw, member: member, sum: 5) }
        let(:token) { jwt_for(member) }

        it 'returns current user balances' do
         api_get '/api/v2/account/balances', token: token
         expect(response).to have_http_status 200
         result = JSON.parse(response.body)
         expect(result).to contain_exactly(
                        { 'account_type' => 'spot', 'currency' => 'btc', 'balance' => '5.0', 'locked' => '5.0', 'deposit_address' => nil, 'deposit_addresses' => [] },
                        { 'account_type' => 'spot', 'currency' => 'eth', 'balance' => '30.5', 'locked' => '0.0', 'deposit_address' => nil, 'deposit_addresses' => [] },
                        { 'account_type' => 'spot', 'currency' => 'usd', 'balance' => '0.0', 'locked' => '0.0' },
                        { 'account_type' => 'spot', 'currency' => 'trst', 'balance' => '0.0', 'locked' => '0.0', 'deposit_address' => nil, 'deposit_addresses' => [] },
                        { 'account_type' => 'spot', 'currency' => 'ring', 'balance' => '0.0', 'locked' => '0.0', 'deposit_address' => nil, 'deposit_addresses' => [] },
                        { 'account_type' => 'spot', 'currency' => 'eur', 'balance' => '0.0', 'locked' => '0.0' })
        end
      end
    end

    context 'use nonzero parameter == true' do
      before { api_get '/api/v2/account/balances', token: token, params: {nonzero: true} }

      it 'returns nonzero balances' do
        expect(response).to have_http_status 200
        result = JSON.parse(response.body)
        expect(result).to contain_exactly(
                            { 'currency' => 'btc',  'balance' => '5.0',  'locked'  => '5.0', 'account_type' => 'spot', 'deposit_address' => nil, 'deposit_addresses' => [] },
                            { 'currency' => 'eth',  'balance' => '30.5', 'locked'  => '0.0', 'account_type' => 'spot', 'deposit_address' => nil, 'deposit_addresses' => [] },
                            )
      end
    end

    context 'use nonzero parameter == false' do
      before { api_get '/api/v2/account/balances', token: token, params: {nonzero: false} }

      it 'returns all balances' do
        expect(response).to have_http_status 200
        result = JSON.parse(response.body)
        expect(result).to contain_exactly(
                              { 'currency' => 'btc',  'balance' => '5.0',  'locked'  => '5.0', 'account_type' => 'spot', 'deposit_address' => nil, 'deposit_addresses' => [] },
                              { 'currency' => 'eth',  'balance' => '30.5', 'locked'  => '0.0', 'account_type' => 'spot', 'deposit_address' => nil, 'deposit_addresses' => [] },
                              { 'currency' => 'usd',  'balance' => '0.0',  'locked'  => '0.0', 'account_type' => 'spot' },
                              { 'currency' => 'trst',  'balance' => '0.0',  'locked'  => '0.0', 'account_type' => 'spot', 'deposit_address' => nil, 'deposit_addresses' => [] },
                              { 'currency' => 'ring',  'balance' => '0.0',  'locked'  => '0.0', 'account_type' => 'spot', 'deposit_address' => nil, 'deposit_addresses' => [] },
                              { 'currency' => 'eur',  'balance' => '0.0',  'locked'  => '0.0', 'account_type' => 'spot' },
                              )
      end
    end

    context 'use nonzero parameter == string' do
      before { api_get '/api/v2/account/balances', token: token, params: {nonzero: "token"} }


      it 'returns all balances' do
        expect(response).to have_http_status 422
        result = JSON.parse(response.body)
        expect(result).to contain_exactly(["errors", ["account.balances.invalid_nonzero"]])
      end
    end

    context 'pagination' do
      before { api_get '/api/v2/account/balances', {token: token, params: {limit: 2} } }

      it 'limited user balances' do
        result = JSON.parse(response.body)
        expect(response).to be_successful

        expect(response.headers.fetch('Total').to_i).to eq member.accounts.count

        expect(result.size).to eq(2)
      end
    end

    context 'disable currency' do

      before do
        Currency.find(:eth).update(status: :disabled)
        api_get '/api/v2/account/balances', token: token
      end

      it 'returns only balances of enabled currencies' do
        result = JSON.parse(response.body)
        expect(result.count).to eq 5
      end

    end

    context 'filters' do
      context 'currency_code' do
        it 'filters by currency_code 1' do
          api_get '/api/v2/account/balances', token: token, params: { search: {currency_code: 't'}}
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('currency')).to contain_exactly('btc', 'eth', 'trst')
        end

        it 'filters by currency_code 2' do
          api_get '/api/v2/account/balances', token: token, params: { search: {currency_code: 'TrSt'}}
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('currency')).to contain_exactly('trst')
        end

        it 'filters by currency_code 3' do
          api_get '/api/v2/account/balances', token: token, params: { search: {currency_code: 'abc'}}
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.blank?).to be_truthy
        end
      end

      context 'currency_name' do
        it 'filters by currency_name 1' do
          api_get '/api/v2/account/balances', token: token, params: { search: {currency_name: 'Et'}}
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('currency')).to contain_exactly('eth', 'trst')
        end

        it 'filters by currency_name 2' do
          api_get '/api/v2/account/balances', token: token, params: { search: {currency_name: 'dollar'}}
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('currency')).to contain_exactly('usd')
        end

        it 'filters by currency_name 3' do
          api_get '/api/v2/account/balances', token: token, params: { search: {currency_name: 'abc'}}
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.blank?).to be_truthy
        end
      end

      context 'currency_code & currency_name' do
        it 'filters by code or name 1' do
          api_get '/api/v2/account/balances', token: token, params: { search: {currency_name: 'abc', currency_code: 'TrSt'}}
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('currency')).to contain_exactly('trst')
        end

        it 'filters by code or name 2' do
          api_get '/api/v2/account/balances', token: token, params: { search: {currency_name: 'Trust', currency_code: 'abc'}}
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('currency')).to contain_exactly('trst')
        end

        it 'filters by code or name 3' do
          api_get '/api/v2/account/balances', token: token, params: { search: {currency_name: 'Eu', currency_code: 'ri'}}
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result.pluck('currency')).to contain_exactly('ring', 'eur', 'eth')
        end
      end
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      before { api_get '/api/v2/account/balances', {token: token, params: {limit: 2} } }

      it 'renders unauthorized error' do
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end

    context 'email changed' do
      let(:new_member_email) { Faker::Internet.email }

      it do
        old_member_email = member.email
        member.email = new_member_email
        api_get '/api/v2/account/balances', {token: jwt_for(member), params: {limit: 2} }
        expect(response).to be_successful

        member.reload
        expect(member.email).to eq new_member_email
        expect(member.email).to_not eq old_member_email
      end

    end
  end

  describe 'GET api/v2/account/balances/:currency' do

    before { api_get '/api/v2/account/balances/eth', token: token }

    it 'returns current user balance by currency' do
      expect(response).to have_http_status 200
      result = JSON.parse(response.body)
      expect(result).to match response_body
    end

    context 'currency code with dot' do
      let!(:currency) { create(:currency, :xagm_cx) }
      let!(:account) { ::Account.create(currency_id: 'xagm.cx', member_id: member.id)}

      it 'returns current user balance by currency' do
        api_get "/api/v2/account/balances/#{currency.code}", token: token

        expect(response).to have_http_status 200
        result = JSON.parse(response.body)
        expect(result['currency']).to eq currency.code
      end
    end

    context 'invalid currency' do

      before { api_get '/api/v2/account/balances/somecoin', token: token }

      it do
        expect(response).to have_http_status 422
        expect(response).to include_api_error('account.currency.doesnt_exist')
      end

    end

    context 'disable currency' do

      before do
        Currency.find(:eth).update(status: :disabled)
        api_get '/api/v2/account/balances/eth', token: token
      end

      it do
        expect(response).to have_http_status 422
      end

    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      before { api_get '/api/v2/account/balances/eth', token: token }

      it 'renders unauthorized error' do
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end
  end
end
