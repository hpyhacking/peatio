# frozen_string_literal: true

describe API::V2::Account::InternalTransfers, type: :request do
  let(:endpoint) { '/api/v2/account/internal_transfers' }
  let(:member) { create(:member, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0',  username: 'membertest') }
  let(:member_receiver) { create(:member, :level_3, email: 'receiver@gmail.com', uid: 'ID84BF61C8H0', username: 'test1') }
  let(:token) { jwt_for(member) }

  describe 'GET /api/v2/account/internal_transfers' do
    let!(:internal_transfer_btc) { create_list(:internal_transfer_btc, 4, :with_deposit_liability, sender: member) }
    let!(:internal_transfer_usd) { create_list(:internal_transfer_usd, 6, :with_deposit_liability, sender: member_receiver) }
    let!(:internal_transfer_usd) { create_list(:internal_transfer_usd, 3, :with_deposit_liability, receiver: member) }

    context 'unauthorized' do
      before do
        Ability.stubs(:user_permissions).returns([])
      end

      it 'renders unauthorized error' do
        api_get endpoint, token: token, params: { limit: 100 }
        expect(response).to have_http_status 403
        expect(response).to include_api_error('user.ability.not_permitted')
      end
    end

    it 'requires authentication' do
      get endpoint
      expect(response.code).to eq '401'
    end

    it 'validates currency param' do
      api_get endpoint, params: { currency: 'FOO' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('account.currency.doesnt_exist')
    end

    it 'returns internal transfers for all currencies by default' do
      api_get endpoint, params: { limit: 100 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '7'
      expect(result.map { |x| x['currency'] }.uniq.sort).to eq %w[ btc usd ]
    end

    it 'returns all internal transfers' do
      api_get endpoint, token: token
      result = JSON.parse(response.body)

      expect(result.size).to eq 7
      expect(response.headers.fetch('Total')).to eq '7'
    end

    it 'returns internal transfers of BTC currency' do
      api_get endpoint, params: { currency: 'btc' }, token: token
      result = JSON.parse(response.body)

      expect(result.count).to eq 4
    end

    it 'returns internal transfers of USD currency' do
      api_get endpoint, params: { currency: 'usd' }, token: token
      result = JSON.parse(response.body)

      expect(result.count).to eq 3
    end
  end

  describe "create internal transfer" do
    let(:currency) { Currency.visible.sample; Currency.find(:eth) }
    let(:amount) { 0.15 }

    let :data do
      { username_or_uid:            member_receiver.uid,
        currency:                   currency.code,
        amount:                     amount,
        otp:                        123456 }
    end

    let(:account) { member.get_account(currency) }
    let(:balance) { 1.2 }
    before { account.plus_funds(balance) }

    before { Vault::TOTP.stubs(:validate?).returns(true) }

    it 'validates missing params' do
      data.except!(:otp, :amount, :currency, :username_or_uid)
      api_post endpoint, params: data, token: token

      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.internaltransfer.missing_otp')
      expect(response).to include_api_error('account.internaltransfer.missing_amount')
      expect(response).to include_api_error('account.internaltransfer.missing_currency')
      expect(response).to include_api_error('account.internaltransfer.empty_username_or_uid')
    end

    it 'requires otp' do
      data[:otp] = nil
      api_post endpoint, params: data, token: token

      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.internaltransfer.empty_otp')
    end

    it 'validates otp code' do
      Vault::TOTP.stubs(:validate?).returns(false)
      api_post endpoint, params: data, token: token

      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.internal_transfer.invalid_otp')
    end

    it 'requires amount' do
      data[:amount] = nil
      api_post endpoint, params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.internal_transfer.non_positive_amount')
    end

    it 'validates negative amount' do
      data[:amount] = -1
      api_post endpoint, params: data, token: token

      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.internal_transfer.non_positive_amount')
    end

    it 'validates enough balance' do
      data[:amount] = 100
      api_post endpoint, params: data, token: token

      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.internal_transfer.insufficient_balance')
    end

    it 'validates amount type' do
      data[:amount] = 'one'
      api_post endpoint, params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.internal_transfer.non_decimal_amount')
    end

    it 'requires currency' do
      data[:currency] = nil
      api_post endpoint, params: data, token: token
      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.currency.doesnt_exist')
    end

    it 'creates new internal_transfer' do
      api_post endpoint, params: data, token: token

      expect(response).to have_http_status(201)
      record = InternalTransfer.last

      expect(record.sender_id).to eq member.id
      expect(record.receiver_id).to eq member_receiver.id
      expect(record.amount).to eq amount
      expect(record.currency).to eq currency
    end

    it 'creates new internal_transfer using username' do
      data[:username_or_uid] = member_receiver.username
      api_post endpoint, params: data, token: token

      expect(response).to have_http_status(201)
      record = InternalTransfer.last

      expect(record.sender_id).to eq member.id
      expect(record.receiver_id).to eq member_receiver.id
      expect(record.amount).to eq amount
      expect(record.currency).to eq currency
    end

    it 'should change balance for receiver and sender after transfer' do
      api_post endpoint, params: data, token: token
      account.reload.balance

      expect(response).to have_http_status(201)
      record = InternalTransfer.last

      expect(account.balance).to eq (balance - amount)
      expect(member_receiver.get_account(currency.code).balance).to eq amount
    end

    it 'not allow create new internal_transfer to yourself' do
      data[:username_or_uid] = member.uid
      api_post endpoint, params: data, token: token

      expect(response).to have_http_status(422)
      expect(response).to include_api_error('account.internal_transfer.can_not_tranfer_to_yourself')
    end
  end
end
