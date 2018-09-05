# encoding: UTF-8
# frozen_string_literal: true

describe Admin::CurrenciesController, type: :controller do
  let(:member) { create(:admin_member) }
  let :attributes do
    { code:                             'nbn',
      blockchain_key:                   Blockchain.first.key,
      type:                             'coin',
      symbol:                           'N',
      quick_withdraw_limit:             '1.5'.to_d,
      withdraw_fee:                     '0.001'.to_d,
      deposit_fee:                      '0.0'.to_d,
      enabled:                          true,
      base_factor:                      1000000,
      precision:                        8,
      erc20_contract_address:           '1fmiowizbqnrkhzrn4vvsmqacc5gvk9sf3' }

  end

  let(:existing_currency) { Currency.first }

  before { session[:member_id] = member.id }

  describe '#create' do
    it 'creates market with valid attributes' do
      expect do
        post :create, currency: attributes
        expect(response).to redirect_to admin_currencies_path
      end.to change(Currency, :count)
      currency = Currency.find(:nbn)
      attributes.each { |k, v| expect(currency.method(k).call).to eq v }
    end
  end

  describe '#update' do
    let :new_attributes do
      { code:                             'mkd',
        type:                             'fiat',
        symbol:                           'X',
        quick_withdraw_limit:             '5.55'.to_d,
        withdraw_fee:                     '0.006'.to_d,
        deposit_fee:                      '0.05'.to_d,
        enabled:                          false,
        base_factor:                      100000,
        precision:                        9,
        erc20_contract_address:           '12kAmv8QXvQyosGzitFYm6YzxK2SgovhQ9' }

    end

    let :final_attributes do
      new_attributes.merge(deposit_fee: '0.0'.to_d).merge \
        attributes.slice \
          :code,
          :type,
          :base_factor,
          :precision,
          :erc20_contract_address
    end

    before { request.env['HTTP_REFERER'] = '/admin/currencies' }

    it 'updates currency attributes' do
      post :create, currency: attributes
      currency = Currency.find(:nbn)
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
