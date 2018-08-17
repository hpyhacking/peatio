# encoding: UTF-8
# frozen_string_literal: true

describe Admin::WalletsController, type: :controller do
  let(:member) { create(:admin_member) }
  let(:existing_currency) { Currency.find('eth') }
  let :attributes do
    { currency_id:        existing_currency.id,
      name:               'New Ethereum Hot Wallet',
      address:            '249048804499541338815845805798634312140346616732',
      kind:               'hot',
      nsig:               2,
      status:             'active',
      gateway:            'geth',
      uri:                'http://127.0.0.1:8545',
      secret:             'changeme'
    }
  end

  let(:existing_wallet) { Wallet.first }

  before { session[:member_id] = member.id }

  describe '#create' do
    it 'creates wallet with valid attributes' do
      expect do
        post :create, wallet: attributes
        expect(response).to redirect_to admin_wallets_path
      end.to change(Wallet, :count).by(1)
      wallet = Wallet.last
      attributes.each { |k, v| expect(wallet.method(k).call).to eq v }
    end
  end

  describe '#update' do
    let :new_attributes do
      { currency_id:        existing_currency.id,
        name:               'Ethereum Warm Wallet',
        address:            '249048804499541338815845805798634312140346616732',
        kind:               'warm',
        nsig:               5,
        status:             'disabled',
        gateway:            'geth',
        uri:                'http://127.0.0.1:8545',
        secret:             'changeme'
      }
    end

    before { request.env['HTTP_REFERER'] = '/admin/wallets' }

    it 'updates wallet attributes' do
      wallet = Wallet.last
      post :update, wallet: new_attributes, id: wallet.id
      expect(response).to redirect_to admin_wallets_path
      wallet.reload
      new_attributes.each { |k, v| expect(wallet.method(k).call).to eq v }
    end
  end

  describe '#destroy' do
    it 'doesn\'t support deletion of wallet' do
      expect { delete :destroy, id: existing_wallet.id }.to raise_error(ActionController::UrlGenerationError)
    end
  end


end
