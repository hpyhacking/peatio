# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Account::Withdraws, type: :request do
  let(:member) { create(:member, :level_3) }
  let(:token) { jwt_for(member) }
  let(:level_0_member) { create(:member, :level_0) }
  let(:level_0_member_token) { jwt_for(level_0_member) }

  before do
    Ability.stubs(:user_permissions).returns({'member'=>{'read'=>['Withdraw'],'create'=>['Withdraw']}})
  end

  describe 'GET /api/v2/account/withdraws' do
    let!(:btc_withdraws) { create_list(:btc_withdraw, 20, :with_deposit_liability, member: member, updated_at: 5.days.ago) }
    let!(:usd_withdraws) { create_list(:usd_withdraw, 20, :with_deposit_liability, member: member, updated_at: 2.hour.ago) }

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      it 'renders unauthorized error' do
        api_get '/api/v2/account/withdraws', token: token

        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end

    it 'requires authentication' do
      get '/api/v2/account/withdraws'
      expect(response.code).to eq '401'
    end

    it 'validates currency param' do
      api_get '/api/v2/account/withdraws', params: { currency: 'FOO' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.currency.doesnt_exist')
    end

    it 'validates page param' do
      api_get '/api/v2/account/withdraws', params: { page: -1 }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.withdraw.non_positive_page')
    end

    it 'validates limit param' do
      api_get '/api/v2/account/withdraws', params: { limit: 9999 }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.withdraw.invalid_limit')
    end

    it 'validates time_from param' do
      api_get '/api/v2/account/withdraws', params: { time_from: 'btc' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.withdraw.non_integer_time_from')
    end

    it 'validates time_to param' do
      api_get '/api/v2/account/withdraws', params: { time_to: [] }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.withdraw.non_integer_time_to')
    end

    it 'returns withdraws for all currencies by default' do
      api_get '/api/v2/account/withdraws', params: { limit: 100 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '40'
      expect(result.map { |x| x['currency'] }.uniq.sort).to eq %w[ btc usd ]
    end

    it 'returns withdraws specified currency' do
      api_get '/api/v2/account/withdraws', params: { currency: 'btc', limit: 100 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '20'
      expect(result.map { |x| x['currency'] }.uniq.sort).to eq %w[ btc ]
    end

    it 'returns withdraws with blockchain key filter' do
      api_get '/api/v2/account/withdraws', params: { blockchain_key: btc_withdraws.first.blockchain_key }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.size).to eq 20
      expect(result.all? { |d| d['blockchain_key'] == 'btc-testnet' }).to be_truthy
    end

    it 'returns withdraws with txid filter' do
      api_get '/api/v2/account/withdraws', params: { rid: btc_withdraws.first.rid }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 1
      expect(result.all? { |d| d['rid'] == btc_withdraws.first.rid }).to be_truthy
    end


    it 'filters withdraws by multiple states' do
      create(:usd_withdraw, member: member, aasm_state: :rejected)
      api_get '/api/v2/account/withdraws', params: { state: ['canceled', 'rejected'] }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 1

      create(:usd_withdraw, member: member, aasm_state: :canceled)
      api_get '/api/v2/account/withdraws', params: { state: ['canceled', 'rejected'] }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 2
    end

    it 'returns withdraws for the last two days' do
      api_get '/api/v2/account/withdraws', params: { time_from: 2.days.ago.to_i }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 20
      expect(response.headers.fetch('Total')).to eq '20'
    end

    it 'returns withdraws before 2 days ago' do
      api_get '/api/v2/account/withdraws', params: { time_to: 2.days.ago.to_i }, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 20
      expect(response.headers.fetch('Total')).to eq '20'
    end

    it 'paginates withdraws' do
      ordered_withdraws = btc_withdraws.sort_by(&:id).reverse

      api_get '/api/v2/account/withdraws', params: { currency: 'btc', limit: 10, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '20'
      expect(result.first['id']).to eq ordered_withdraws[0].id

      api_get '/api/v2/account/withdraws', params: { currency: 'btc', limit: 10, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '20'
      expect(result.first['id']).to eq ordered_withdraws[10].id
    end

    it 'sorts withdraws' do
      ordered_withdraws = btc_withdraws.sort_by(&:id).reverse

      api_get '/api/v2/account/withdraws', params: { currency: 'btc', limit: 100 }, token: token
      expect(response).to be_successful
      result = JSON.parse(response.body)

      expect(result.map { |x| x['id'] }).to eq ordered_withdraws.map(&:id)
      expect(result.map { |x| x['protocol'] }).to eq ordered_withdraws.map(&:protocol)
    end

    it 'denies access to unverified member' do
      api_get '/api/v2/account/withdraws', token: level_0_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('account.withdraw.not_permitted')
    end
  end

  describe 'create withdraw' do
    let(:currency) { Currency.visible.sample; Currency.find(:usd) }
    let(:amount) { 0.15 }

    let(:beneficiary) do
      create(:beneficiary, member: member, state: :active, currency: currency)
    end

    let :data do
      { uid:            member.uid,
        currency:       currency.code,
        amount:         amount,
        beneficiary_id: beneficiary.id,
        otp:            123456 }
    end

    let(:account) { member.get_account(currency) }
    let(:balance) { 1.2 }
    let(:long_note) { (0...257).map { (65 + rand(26)).chr }.join }
    before { account.plus_funds(balance) }
    before { Vault::TOTP.stubs(:validate?).returns(true) }

    context 'extremely precise values' do
      before { BlockchainCurrency.any_instance.stubs(:withdraw_fee).returns(BigDecimal(0)) }
      before { Currency.any_instance.stubs(:precision).returns(16) }
      it 'keeps precision for amount' do
        data[:amount] = '0.0000000123456789'
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status(201)
        expect(Withdraw.last.sum.to_s).to eq data[:amount]
      end
    end

    it 'validates missing params' do
      data.except!(:otp, :amount, :currency, :beneficiary_id)
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.missing_otp')
      expect(response).to include_api_error('account.withdraw.missing_amount')
      expect(response).to include_api_error('account.withdraw.missing_currency')
    end

    it 'validates missing beneficiary_id' do
      data.except!(:beneficiary_id).merge!(rid: 'some_addres', blockchain_key: 'eth-kovan')
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.missing_beneficiary_id')
    end

    it 'validates missing blokchain_key if rid is given' do
      data.except!(:beneficiary_id).merge!(rid: 'some_addres')
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.missing_blockchain_key')
    end

    it 'validates missing rid and beneficiary_id' do
      data.except!(:beneficiary_id)
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.missing_rid_or_beneficiary_id')
    end

    context 'invalid beneficiary_id' do
      context 'non-existing' do
        it do
          data[:beneficiary_id] = data[:beneficiary_id] + 1
          api_post '/api/v2/account/withdraws', params: data, token: token
          expect(response).to have_http_status(422)
          expect(response).to include_api_error('account.beneficiary.doesnt_exist')
        end
      end

      context 'archived' do
        before { beneficiary.update(state: :archived) }
        it do
          api_post '/api/v2/account/withdraws', params: data, token: token
          expect(response).to have_http_status(422)
          expect(response).to include_api_error('account.beneficiary.doesnt_exist')
        end
      end

      context 'pending' do
        before { beneficiary.update(state: :pending) }
        it do
          api_post '/api/v2/account/withdraws', params: data, token: token
          expect(response).to have_http_status(422)
          expect(response).to include_api_error('account.beneficiary.invalid_state_for_withdrawal')
        end
      end
    end

    it 'requires beneficiary_id' do
      data[:beneficiary_id] = nil
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.empty_beneficiary_id')
    end

    it 'validates beneficiary_id type' do
      data[:beneficiary_id] = 'beneficiary_id'
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.non_integer_beneficiary_id')
    end

    it 'requires otp' do
      data[:otp] = nil
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.empty_otp')
    end

    it 'validates otp code' do
      Vault::TOTP.stubs(:validate?).returns(false)
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.invalid_otp')
    end

    it 'requires amount' do
      data[:amount] = nil
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.non_positive_amount')
    end

    it 'validates negative amount' do
      data[:amount] = -1
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.non_positive_amount')
    end

    it 'validates enough balance' do
      data[:amount] = 100
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.insufficient_balance')
    end

    it 'validates amount type' do
      data[:amount] = 'one'
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.non_decimal_amount')
    end

    it 'validates amount precision' do
      data[:amount] = 0.123456789123456789
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.invalid_amount')
    end

    it 'requires currency' do
      data[:currency] = nil
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.currency.doesnt_exist')
    end

    it 'disabled currency' do
      data[:currency] = :eur
      api_post '/api/v2/account/withdraws', params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.currency.doesnt_exist')
    end

    context 'disabled withdrawal for currency' do
      let(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: 'usd') }

      before do
        blockchain_currency.update!(withdrawal_enabled: false)
      end

      it 'returns error' do
        api_post '/api/v2/account/withdraws', params: data, token: token
        expect(response).to have_http_status 422
        expect(response).to include_api_error('account.currency.withdrawal_disabled')
      end
    end

    it 'creates new withdraw and immediately submits it' do
      api_post '/api/v2/account/withdraws', params: data, token: token

      expect(response).to have_http_status(201)
      record = Withdraw.last
      expect(record.sum).to eq amount
      expect(record.blockchain_key).to eq Withdraw.last.beneficiary.blockchain_key
      expect(record.aasm_state).to eq 'accepted'
      expect(record.account).to eq account
      expect(record.account.balance).to eq(1.2 - amount)
      expect(record.account.locked).to eq amount
    end

    it 'creates new withdraw with note' do
      api_post '/api/v2/account/withdraws', params: data.merge(note: 'Test note'), token: token
      expect(response).to have_http_status(201)

      result = JSON.parse(response.body)
      expect(result['note']).to eq 'Test note'

      record = Withdraw.last
      expect(record.note).to eq 'Test note'
    end

    it 'doesnt create new withdraw with too long note' do
      api_post '/api/v2/account/withdraws', params: data.merge(note: long_note), token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.withdraw.too_long_note')
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      it 'renders unauthorized error' do
        api_post '/api/v2/account/withdraws', params: data, token: token

        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end
  end

  describe 'GET /withdraws/sums' do
    let!(:btc_withdraws) { create_list(:btc_withdraw, 2, :with_deposit_liability, member: member) }
    let!(:usd_withdraws) { create_list(:usd_withdraw, 2, :with_deposit_liability, member: member) }

    before do
      btc_withdraws.map(&:accept!)
      usd_withdraws.map(&:accept!)
    end

    it 'returns withdrawals sums' do
      api_get '/api/v2/account/withdraws/sums', token: token

      expect(response_body.key?('last_24_hours')).to be_truthy
      expect(response_body.key?('last_1_month')).to be_truthy
    end

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      it 'renders unauthorized error' do
        api_get '/api/v2/account/withdraws/sums', token: token

        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end
  end
end
