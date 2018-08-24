# encoding: UTF-8
# frozen_string_literal: true

describe Worker::DepositCollection do
  describe 'Deposit Collection' do
    let(:deposit) { create(:deposit_btc) }
    let(:wallet) { Wallet.find_by_blockchain_key('btc-testnet') }
    let(:wallet_service) { WalletService[wallet] }
    let(:txid) { Faker::Lorem.characters(64) }
    before do
      wallet_service.class.any_instance
          .expects(:collect_deposit!)
          .with(deposit)
          .returns(txid: txid)
    end

    it 'should run successfully' do
      expect(Worker::DepositCollection.new.process(deposit)).to be_truthy
    end
  end
end
