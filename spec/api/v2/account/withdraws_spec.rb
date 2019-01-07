# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Account::Withdraws, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:level_0_member) { create(:member, :level_0) }
  let(:level_0_member_token) { jwt_for(level_0_member) }

  describe 'GET /api/v2/account/withdraws' do
    let!(:btc_withdraws) { create_list(:btc_withdraw, 20, member: member) }
    let!(:usd_withdraws) { create_list(:usd_withdraw, 20, member: member) }

    it 'require authentication' do
      get '/api/v2/account/withdraws'
      expect(response.code).to eq '401'
    end

    it 'validates currency param' do
      api_get '/api/v2/account/withdraws', params: { currency: 'FOO' }, token: token
      expect(response.code).to eq '422'
      expect(response.body).to eq '{"error":{"code":1001,"message":"currency does not have a valid value"}}'
    end

    it 'validates page param' do
      api_get '/api/v2/account/withdraws', params: { page: -1 }, token: token
      expect(response.code).to eq '422'
      expect(response.body).to eq '{"error":{"code":1001,"message":"page page must be greater than zero."}}'
    end

    it 'validates limit param' do
      api_get '/api/v2/account/withdraws', params: { limit: 9999 }, token: token
      expect(response.code).to eq '422'
      expect(response.body).to eq '{"error":{"code":1001,"message":"limit must be in range: 1..1000."}}'
    end

    it 'returns withdraws for all currencies by default' do
      api_get '/api/v2/account/withdraws', params: { limit: 1000 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).map { |x| x['currency'] }.uniq.sort).to eq %w[ btc usd ]
    end

    it 'returns withdraws specified currency' do
      api_get '/api/v2/account/withdraws', params: { currency: 'BTC', limit: 1000 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).map { |x| x['currency'] }.uniq.sort).to eq %w[ btc ]
    end

    it 'paginates withdraws' do
      ordered_withdraws = btc_withdraws.sort_by(&:id).reverse

      api_get '/api/v2/account/withdraws', params: { currency: 'BTC', limit: 10, page: 1 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq ordered_withdraws[0].id

      api_get '/api/v2/account/withdraws', params: { currency: 'BTC', limit: 10, page: 2 }, token: token
      expect(response).to be_success
      expect(JSON.parse(response.body).first['id']).to eq ordered_withdraws[10].id
    end

    it 'sorts withdraws' do
      ordered_withdraws = btc_withdraws.sort_by(&:id).reverse

      api_get '/api/v2/account/withdraws', params: { currency: 'BTC', limit: 100 }, token: token
      expect(response).to be_success
      results = JSON.parse(response.body)
      expect(results.map { |x| x['id'] }).to eq ordered_withdraws.map(&:id)
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/account/withdraws', token: level_0_member_token
      expect(response.code).to eq '403'
      expect(JSON.parse(response.body)['error']).to eq( {'code' => 2000, 'message' => 'Please, pass the corresponding verification steps to withdraw funds.'} )
    end
  end

  describe 'create withdraw' do
    let(:currency) { Currency.coins.sample }
    let(:amount) { 0.1575 }
    let :data do
      { uid:      member.uid,
        currency: currency.code,
        amount:   amount,
        rid:      Faker::Bitcoin.address,
        otp:      123456 }
    end
    let(:account) { member.accounts.with_currency(currency).first }
    let(:balance) { 1.2 }
    before { account.plus_funds(balance) }
    before { Vault::TOTP.stubs(:validate?).returns(true) }

    context 'fiat withdrawal' do
      before { data[:currency] = Currency.fiats.pluck(:id).sample }
      it 'doesn\'t allow fiat' do
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(422)
        expect(response.body).to eq '{"error":{"code":1001,"message":"currency does not have a valid value"}}'
      end
    end

    context 'crypto withdrawal' do
      context 'disabled account withdrawal API' do
        before { ENV['ENABLE_ACCOUNT_WITHDRAWAL_API'] = 'false' }
        after { ENV['ENABLE_ACCOUNT_WITHDRAWAL_API'] = 'true' }
        it 'doesn\'t allow account withdrawal API call' do
          api_post '/api/v2/account/withdraws', params: data, token: token
          expect(response).to have_http_status(422)
          expect(response.body).to eq '{"error":{"code":2000,"message":"Account withdrawal API is disabled"}}'
        end
      end

      context 'extremely precise values' do
        before { Currency.any_instance.stubs(:withdraw_fee).returns(BigDecimal(0)) }
        before { Currency.any_instance.stubs(:precision).returns(16) }
        it 'keeps precision for amount' do
          currency.update!(precision: 16)
          data[:amount] = '0.0000000123456789'
          api_post '/api/v2/account/withdraws', params: data, token: token
          expect(response).to have_http_status(201)
          expect(Withdraw.last.sum.to_s).to eq data[:amount]
        end
      end

      it 'validates missing otp param' do
        data.except!(:otp)
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(422)
        expect(response.body).to eq '{"error":{"code":1001,"message":"otp is missing, otp is empty"}}'
      end

      it 'requires otp' do
        data[:otp] = nil
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(422)
        expect(response.body).to eq '{"error":{"code":1001,"message":"otp is empty"}}'
      end

      it 'validates otp code' do
        Vault::TOTP.stubs(:validate?).returns(false)
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(422)
        expect(response.body).to eq '{"error":{"code":2000,"message":"OTP code is invalid"}}'
      end

      it 'requires amount' do
        data[:amount] = nil
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(422)
        expect(response.body).to eq '{"error":{"code":1001,"message":"amount must be positive"}}'
      end

      it 'validates negative balance' do
        data[:amount] = -1
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(422)
        expect(response.body).to eq '{"error":{"code":1001,"message":"amount must be positive"}}'
      end

      it 'validates enough balance' do
        data[:amount] = 100
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(422)
        expect(response.body).to eq '{"errors":["Account balance is insufficient"]}'
      end

      it 'requires rid' do
        data[:rid] = nil
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(422)
        expect(response.body).to eq '{"error":{"code":1001,"message":"rid is empty"}}'
      end

      it 'requires currency' do
        data[:currency] = nil
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(422)
        expect(response.body).to eq '{"error":{"code":1001,"message":"currency does not have a valid value"}}'
      end

      it 'creates new withdraw and immediately submits it' do
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(201)
        record = Withdraw.last
        expect(record.sum).to eq 0.1575
        expect(record.aasm_state).to eq 'submitted'
        expect(record.account).to eq account
        expect(record.account.balance).to eq(1.2 - amount)
        expect(record.account.locked).to eq amount
      end
    end
  end
end
