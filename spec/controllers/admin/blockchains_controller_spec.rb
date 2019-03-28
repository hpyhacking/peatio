# encoding: UTF-8
# frozen_string_literal: true

describe Admin::BlockchainsController, type: :controller do
  let(:member) { create :admin_member }
  before(:each) { inject_authorization!(member) }

  let :attributes do
    { key:                              'eth-rinkeby-new',
      name:                             'Ethereum Rinkeby',
      client:                           'eth',
      server:                           'http://127.0.0.1:8545',
      height:                           250_000_0,
      min_confirmations:                3,
      explorer_address:                 'https://etherscan.io/address/\#{address}',
      explorer_transaction:             'https://etherscan.io/tx/\#{txid}',
      status:                           'active'
    }
  end

  let(:existing_blockchain) { Blockchain.first }

  describe '#create' do
    it 'creates blockchain with valid attributes' do
      expect do
        post :create, params: { blockchain: attributes }
        expect(response).to redirect_to admin_blockchains_path
      end.to change(Blockchain, :count).by(1)
      blockchain = Blockchain.last
      attributes.each { |k, v| expect(blockchain.method(k).call).to eq v }
    end
  end

  describe '#update' do
    let :new_attributes do
      { key:                              'btc-test',
        name:                             'Bitcoin Testnet',
        client:                           'btc',
        server:                           'http://127.0.0.1:18332',
        height:                           300_000_0,
        min_confirmations:                3,
        explorer_address:                 'https://www.blocktrail.com/BCC/address/\#{address}',
        explorer_transaction:             'https://blockchain.info/tx/\#{txid}',
        status:                           'active'
      }
    end

    before { request.env['HTTP_REFERER'] = '/admin/blockchains' }

    it 'updates blockchain attributes' do
      blockchain = Blockchain.last
      post :update, params: { blockchain: new_attributes, id: blockchain.id }
      expect(response).to redirect_to admin_blockchains_path
      blockchain.reload
      expect(blockchain.attributes.symbolize_keys.except(:id, :created_at, :updated_at)).to eq new_attributes
    end
  end

  describe '#destroy' do
    it 'doesn\'t support deletion of blockchain' do
      expect { delete :destroy, params: { id: existing_blockchain.id } }.to raise_error(ActionController::UrlGenerationError)
    end
  end
end
