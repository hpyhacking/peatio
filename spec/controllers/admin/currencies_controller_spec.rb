describe Admin::CurrenciesController, type: :controller do
  let(:member) { create(:admin_member) }
  let :valid_currency_attributes  do
    { code:   'new',
      type:   'coin',
      symbol: 'N' }
  end
  let(:existing_currency) { Currency.first }

  before { session[:member_id] = member.id }

  describe '#create' do
    it 'creates market with valid attributes' do
      expect do
        post :create, currency: valid_currency_attributes
        expect(response).to redirect_to admin_currencies_path
      end.to change(Currency, :count)
    end
  end

  describe '#update' do
    before do
      valid_currency_attributes
        .except!(:code, :type)
        .merge! \
          quick_withdraw_limit:         1000,
          withdraw_fee:                 0.01,
          deposit_fee:                  0.02,
          visible:                      true,
          base_factor:                  10**6,
          precision:                    6,
          api_client:                   'NEW',
          json_rpc_endpoint:            'http://new.coin',
          rest_api_endpoint:            'http://api.new.coin',
          bitgo_test_net:               true,
          bitgo_wallet_id:              'id',
          bitgo_wallet_address:         'address',
          bitgo_wallet_passphrase:      'passphrase',
          bitgo_rest_api_root:          'http://api.new.coin',
          bitgo_rest_api_access_token:  'token',
          wallet_url_template:          'http://new.coin/ad',
          transaction_url_template:     'http://new.coin/tx'
    end

    before { request.env['HTTP_REFERER'] = '/admin/currencies' }

    it 'updates currency attributes' do
      post :update, currency: valid_currency_attributes, id: existing_currency.id
      expect(response).to redirect_to admin_currencies_path
      valid_currency_attributes.each do |k, v|
        expect(existing_currency.reload.method(k).call).to eq v
      end
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
