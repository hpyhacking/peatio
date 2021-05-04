# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Deposits, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }
  let!(:fiat_deposits) do
    [
      create(:deposit_usd, amount: 10.0),
      create(:deposit_usd, amount: 9.0),
      create(:deposit_usd, amount: 100.0, member: level_3_member),
    ]
  end
  let!(:coin_deposits) do
    [
      create(:deposit_btc, amount: 102.0),
      create(:deposit_btc, amount: 11.0, member: level_3_member),
      create(:deposit_btc, amount: 12.0, member: level_3_member),
    ]
  end

  describe 'GET /api/v2/admin/deposits' do
    let(:url) { '/api/v2/admin/deposits' }

    it 'get all deposits' do
      api_get url, token: token

      actual = JSON.parse(response.body)
      expected = coin_deposits + fiat_deposits

      expect(actual.length).to eq expected.length
      expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
      expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
      expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
      expect(actual.map { |a| a['blockchain_key'] }).to match_array expected.map(&:blockchain_key)
      expect(actual.map { |a| a['member'] }).to match_array expected.map(&:member_id)
      expect(actual.map { |a| a['type'] }).to match_array(expected.map { |d| d.currency.coin? ? 'coin' : 'fiat' })
      expect(actual.map { |a| a['uid'] }).to match_array(expected.map { |d| d.member.uid })
      expect(actual.map { |a| a['email'] }).to match_array(expected.map { |d| d.member.email })
    end

    context 'ordering' do
      it 'default descending by id' do
        api_get url, token: token, params: { order_by: 'id' }

        actual = JSON.parse(response.body)
        expected = (coin_deposits + fiat_deposits).sort { |a, b| b.id <=> a.id }

        expect(actual.map { |a| a['id'] }).to eq expected.map(&:id)
      end

      it 'ascending by id' do
        api_get url, token: token, params: { order_by: 'id', ordering: 'asc' }

        actual = JSON.parse(response.body)
        expected = (coin_deposits + fiat_deposits).sort { |a, b| a.id <=> b.id }

        expect(actual.map { |a| a['id'] }).to eq expected.map(&:id)
      end

      it 'descending by amount' do
        api_get url, token: token, params: { order_by: 'amount', ordering: 'desc' }

        actual = JSON.parse(response.body)
        expected = (coin_deposits + fiat_deposits).sort { |a, b| b.amount <=> a.amount }

        expect(actual.map { |a| a['id'] }).to eq expected.map(&:id)
      end

      it 'ordering by unexisting field' do
        api_get url, token: token, params: { order_by: 'cutiness', ordering: 'desc' }

        actual = JSON.parse(response.body)
        expected = coin_deposits + fiat_deposits

        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
      end
    end

    context 'filtering' do
      let(:blockchain_key) { 'btc-testnet' }

      it 'by member' do
        api_get url, token: token, params: { uid: level_3_member.uid }

        actual = JSON.parse(response.body)
        expected = (coin_deposits + fiat_deposits).select { |d| d.member_id == level_3_member.id }

        expect(actual.length).to eq expected.length
        expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
        expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
        expect(actual.map { |a| a['blockchain_key'] }).to match_array expected.map(&:blockchain_key)
        expect(actual.map { |a| a['member'] }).to all eq level_3_member.id
        expect(actual.map { |a| a['type'] }).to match_array(expected.map { |d| d.currency.coin? ? 'coin' : 'fiat' })
        expect(actual.map { |a| a['uid'] }).to match_array(expected.map { |d| d.member.uid })
        expect(actual.map { |a| a['email'] }).to match_array(expected.map { |d| d.member.email })
      end

      it 'by blockchain_key' do
        api_get url, token: token, params: { blockchain_key: blockchain_key }

        actual = JSON.parse(response.body)
        expected = coin_deposits.select { |d| d.blockchain_key == blockchain_key }

        expect(actual.length).to eq expected.length
        expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
        expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
        expect(actual.map { |a| a['blockchain_key'] }).to match_array expected.map(&:blockchain_key)
        expect(actual.map { |a| a['type'] }).to match_array(expected.map { |d| d.currency.coin? ? 'coin' : 'fiat' })
        expect(actual.map { |a| a['uid'] }).to match_array(expected.map { |d| d.member.uid })
        expect(actual.map { |a| a['email'] }).to match_array(expected.map { |d| d.member.email })
      end

      it 'by type' do
        api_get url, token: token, params: { type: 'coin' }

        actual = JSON.parse(response.body)
        expected = coin_deposits

        expect(actual.length).to eq expected.length
        expect(actual.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
        expect(actual.map { |a| a['id'] }).to match_array expected.map(&:id)
        expect(actual.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
        expect(actual.map { |a| a['member'] }).to match_array expected.map(&:member_id)
        expect(actual.map { |a| a['blockchain_key'] }).to match_array expected.map(&:blockchain_key)
        expect(actual.map { |a| a['type'] }).to all eq 'coin'
      end

      it 'by email' do
        api_get url, token: token, params: { email: level_3_member.email }

        expected = (coin_deposits + fiat_deposits).select { |d| d.member.email == level_3_member.email }

        expect(response_body.length).to eq expected.length
        expect(response_body.map { |a| a['state'] }).to match_array expected.map(&:aasm_state)
        expect(response_body.map { |a| a['id'] }).to match_array expected.map(&:id)
        expect(response_body.map { |a| a['currency'] }).to match_array expected.map(&:currency_id)
        expect(response_body.map { |a| a['member'] }).to all eq level_3_member.id
        expect(response_body.map { |a| a['blockchain_key'] }).to match_array expected.map(&:blockchain_key)
        expect(response_body.map { |a| a['type'] }).to match_array(expected.map { |d| d.currency.coin? ? 'coin' : 'fiat' })
        expect(response_body.map { |a| a['uid'] }).to match_array(expected.map { |d| d.member.uid })
        expect(response_body.map { |a| a['email'] }).to match_array(expected.map { |d| d.member.email })
      end
    end
  end

  describe 'POST /api/v2/admin/deposits/actions' do
    let(:url) { '/api/v2/admin/deposits/actions' }
    let(:fiat) { fiat_deposits.first }
    let!(:coin) { create(:deposit, :deposit_trst, aasm_state: :accepted) }

    context 'validates params' do
      it 'does not pass unsupported action' do
        api_post url, token: token, params: { action: 'illegal', id: fiat.id }

        expect(response.status).to eq 422
        expect(response).to include_api_error('admin.deposit.invalid_action')
      end

      it 'passes supported action for fiat' do
        api_post url, token: token, params: { action: 'reject', id: fiat.id }

        expect(response).not_to include_api_error('admin.deposit.invalid_action')
      end

      it 'does not pass coin action for fiat' do
        api_post url, token: token, params: { action: 'collect', id: fiat.id }

        expect(response.status).to eq 422
        expect(response).to include_api_error('admin.deposit.invalid_action')
      end
    end

    context 'updates deposit' do
      let!(:coin) { create(:deposit, :deposit_trst) }

      it 'accept fiat' do
        api_post url, token: token, params: { action: 'accept', id: fiat.id }
        expect(fiat.reload.aasm_state).to eq('accepted')
        expect(response).to be_successful
      end

      it 'accept coin' do
        api_post url, token: token, params: { action: 'accept', id: coin.id }
        expect(coin.reload.aasm_state).to eq('accepted')
        expect(response).to be_successful
      end

      it 'reject fiat' do
        api_post url, token: token, params: { action: 'reject', id: fiat.id }
        expect(response).to be_successful
        expect(fiat.reload.aasm_state).to eq('rejected')
      end
    end

    context 'action :process' do
      it 'sends event to deposit_collection daemon' do
        api_post url, token: token, params: { action: 'process', id: coin.id }

        expect(response).to be_successful
        expect(Deposit.find(response_body['id']).processing?).to be_truthy
      end

      it 'sends event to deposit_collection daemon' do
        api_post url, token: token, params: { action: 'fee_process', fees: true, id: coin.id }

        expect(response).to be_successful
        expect(Deposit.find(response_body['id']).fee_processing?).to be_truthy
      end
    end
  end

  describe 'POST /api/v2/admin/deposits/new' do
    let(:url) { '/api/v2/admin/deposits/new' }
    let(:fiat) { Currency.find(:usd) }
    let(:coin) { Currency.find(:btc) }

    context 'validates params' do
      it 'returns error when user doesnt exist' do
        api_post url, token: token, params: { uid: SecureRandom.uuid, currency: fiat.code, amount: 12.2 }

        expect(response.status).to eq 422
        expect(response).to include_api_error('admin.deposit.user_doesnt_exist')
      end

      it 'returns error when currency doesnt exist' do
        api_post url, token: token, params: { uid: admin.uid, currency: coin.code, amount: 12.2 }

        expect(response.status).to eq 422
        expect(response).to include_api_error('admin.deposit.currency_doesnt_exist')
      end

      it 'returns error when amount is not decimal' do
        api_post url, token: token, params: { uid: admin.uid, currency: fiat.code, amount: 'amount' }

        expect(response.status).to eq 422
        expect(response).to include_api_error('admin.deposit.non_decimal_amount')
      end
    end

    it 'creates fiat deposit' do
      api_post url, token: token, params: { uid: admin.uid, currency: fiat.code, amount: '13.4' }
      result = JSON.parse(response.body)

      expect(response.status).to eq 201
      expect(result['currency']).to eq fiat.id
      expect(result['member']).to eq admin.id
      expect(result['uid']).to eq admin.uid
      expect(result['email']).to eq admin.email
      expect(result['amount']).to eq '13.4'
      expect(result['type']).to eq 'fiat'
      expect(result['state']).to eq 'submitted'
      expect(result['blockchain_key']).to eq(nil)
      expect(result['transfer_type']).to eq 'fiat'
    end

    it 'return error in case of not permitted ability' do
      api_post url, token: level_3_member_token, params: { uid: admin.uid, currency: fiat.code, amount: 12.1 }

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/deposit_address' do
    let(:url) { '/api/v2/admin/deposit_address' }

    context 'failed' do
      let(:currency) { :eth }

      it 'validates currency with address_format param' do
        api_post url, params: { currency: 'abc', uid: '' }, token: token
        expect(response).to have_http_status 422
        expect(response).to include_api_error('admin.deposit.user_doesnt_exist')
      end

      it 'validates currency' do
        api_post url, params: { currency: 'dildocoin', uid: level_3_member.uid }, token: token
        expect(response).to have_http_status 422
        expect(response).to include_api_error('admin.deposit.currency_doesnt_exist')
      end

      it 'validates blockchain key' do
        api_post url, params: { currency: 'dildocoin', blockchain_key: 'test', uid: level_3_member.uid }, token: token
        expect(response).to have_http_status 422
        expect(response).to include_api_error('admin.deposit.currency_doesnt_exist')
      end

      it 'validates currency address format' do
        api_post url, params: { currency: 'eth', blockchain_key: 'eth-rinkeby', uid: level_3_member.uid, address_format: 'cash' }, token: token
        expect(response).to have_http_status 422
        expect(response).to include_api_error('admin.deposit.doesnt_support_cash_address_format')
      end
    end

    context 'successful' do
      context 'eth address' do
        let(:currency) { :eth }
        let(:wallet) { Wallet.active_deposit_wallet(currency) }
        before { level_3_member.payment_address(wallet.id).update!(address: '2N2wNXrdo4oEngp498XGnGCbru29MycHogR') }

        it 'expose data about eth address' do
          api_post url, params: { currency: currency, blockchain_key: wallet.blockchain_key, uid: level_3_member.uid}, token: token
          expect(response.body).to eq '{"currencies":["eth"],"blockchain_key":"eth-rinkeby","address":"2n2wnxrdo4oengp498xgngcbru29mychogr","state":"active"}'
        end

        it 'pending user address state' do
          level_3_member.payment_address(wallet.id).update!(address: nil)
          api_post url, params: { currency: currency, blockchain_key: wallet.blockchain_key, uid: level_3_member.uid}, token: token
          expect(response.body).to eq '{"currencies":["eth"],"blockchain_key":"eth-rinkeby","address":null,"state":"pending"}'
        end
      end
    end

    context 'disabled deposit for currency' do
      let(:currency) { :btc }
      let(:blockchain_key) { 'btc-testnet' }

      before { BlockchainCurrency.find_by(currency_id: currency).update!(deposit_enabled: false) }

      it 'returns error' do
        api_post url, params: { currency: currency, blockchain_key: blockchain_key, uid: level_3_member.uid}, token: token
        expect(response).to have_http_status 422
        expect(response).to include_api_error('admin.deposit.deposit_disabled')
      end
    end
  end
end
