# encoding: UTF-8
# frozen_string_literal: true

describe Admin::CurrenciesController, type: :controller do
  let(:member) { create(:admin_member) }
  let :attributes do
    { code:                        'nbn',
      type:                        'coin',
      symbol:                      'N',
      quick_withdraw_limit:        '1.5'.to_d,
      withdraw_fee:                '0.001'.to_d,
      deposit_fee:                 '0.0'.to_d,
      deposit_confirmations:       1,
      enabled:                     true,
      wallet_url_template:         'https://blockchain.info/address/#{address}',
      transaction_url_template:    'https://blockchain.info/tx/#{txid}',
      base_factor:                 1000000,
      precision:                   8,
      api_client:                  'NBN',
      json_rpc_endpoint:           'http://127.0.0.1:8888',
      rest_api_endpoint:           'http://127.0.0.1:9999',
      bitgo_test_net:              true,
      bitgo_wallet_id:             '1JFCNxd3bXTEN9La1sxbwAmGrneSix28BF',
      bitgo_wallet_address:        '19S7bZFbeM2ihKTNKBHRbCdJchS9p2BJw7',
      bitgo_wallet_passphrase:     'SECRET',
      bitgo_rest_api_root:         'http://127.0.0.1:1111',
      bitgo_rest_api_access_token: '1ER6jNCoXUfZLq8BCqhAVVdpVBhthDP7oR1PL5YBY2oeNwBoardx4eMpwySBoYdfwwx2',
      case_sensitive:              true,
      erc20_contract_address:      '1FmiowizbQNrkHZRN4VVSmqAcC5gVk9sF3',
      supports_cash_addr_format:   true }
  end

  let(:existing_currency) { Currency.first }

  before { session[:member_id] = member.id }

  describe '#create' do
    it 'creates market with valid attributes' do
      expect do
        post :create, currency: attributes
        expect(response).to redirect_to admin_currencies_path
      end.to change(Currency, :count)
      currency = Currency.last
      attributes.each { |k, v| expect(currency.method(k).call).to eq v }
    end
  end

  describe '#update' do
    let :new_attributes do
      { code:                        'mkd',
        type:                        'fiat',
        symbol:                      'X',
        quick_withdraw_limit:        '5.55'.to_d,
        withdraw_fee:                '0.006'.to_d,
        deposit_fee:                 '0.05'.to_d,
        deposit_confirmations:       4,
        enabled:                     false,
        wallet_url_template:         'https://testnet.blockchain.info/address/#{address}',
        transaction_url_template:    'https://testnet.blockchain.info/tx/#{txid}',
        base_factor:                 100000,
        precision:                   9,
        api_client:                  'MKD',
        json_rpc_endpoint:           'http://127.0.0.1:18888',
        rest_api_endpoint:           'http://127.0.0.1:19999',
        bitgo_test_net:              false,
        bitgo_wallet_id:             '18rKk4bumrDqFevAcs89VAm4C2tAk7rBLo',
        bitgo_wallet_address:        '1MLLGdGK8hgKCMy9rfQKdsdYU1iUzhTCoY',
        bitgo_wallet_passphrase:     'PASSWORD',
        bitgo_rest_api_root:         'http://127.0.0.1:11111',
        bitgo_rest_api_access_token: '1M3jyBNEAgvo2mCCPh1D9gMUsawvBinwkC',
        case_sensitive:              false,
        erc20_contract_address:      '12kAmv8QXvQyosGzitFYm6YzxK2SgovhQ9',
        supports_cash_addr_format:   false }
    end

    let :final_attributes do
      new_attributes.merge(deposit_fee: '0.0'.to_d).merge \
        attributes.slice \
          :code,
          :type,
          :base_factor,
          :precision,
          :api_client,
          :json_rpc_endpoint,
          :rest_api_endpoint,
          :bitgo_test_net,
          :bitgo_wallet_id,
          :bitgo_wallet_address,
          :bitgo_wallet_passphrase,
          :bitgo_rest_api_root,
          :bitgo_rest_api_access_token,
          :case_sensitive,
          :erc20_contract_address,
          :supports_cash_addr_format
    end

    before { request.env['HTTP_REFERER'] = '/admin/currencies' }

    it 'updates currency attributes' do
      post :create, currency: attributes
      currency = Currency.last
      attributes.each { |k, v| expect(currency.method(k).call).to eq v }
      post :update, currency: new_attributes, id: currency.id
      expect(response).to redirect_to admin_currencies_path
      currency.reload
      final_attributes.each { |k, v| expect(currency.method(k).call).to eq v }
    end
  end

  describe '#destroy' do
    it 'doesn\'t support deletion of currencies' do
      expect { delete :destroy, id: existing_currency.id }.to raise_error(ActionController::UrlGenerationError)
    end
  end

  describe 'routes' do
    let(:base_route) { '/admin/currencies' }
    it 'routes to CurrenciesController' do
      expect(get: base_route).to be_routable
      expect(post: base_route).to be_routable
      expect(get: "#{base_route}/new").to be_routable
      expect(get: "#{base_route}/#{existing_currency.id}").to be_routable
      expect(put: "#{base_route}/#{existing_currency.id}").to be_routable
    end

    it 'doesn\'t routes to CurrenciesController' do
      expect(delete: "#{base_route}/#{existing_currency.id}").to_not be_routable
    end
  end
end
