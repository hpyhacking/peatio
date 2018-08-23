# encoding: UTF-8
# frozen_string_literal: true

describe Worker::DepositCoinAddress do
  describe 'BitGo label address' do
    let(:member) { create(:member, :barong) }
    let(:account) { member.ac(:btc) }
    let(:address) { Faker::Bitcoin.address }
    let(:wallet) { Wallet.deposit.find_by_blockchain_key('btc-testnet') }
    let(:wallet_service) { WalletService[wallet] }
    subject { account.payment_address.address }
    before do
      wallet_service.class.any_instance
          .expects(:create_address)
          .with(address_id: nil, label: member.uid)
          .returns(address: address)
    end

    it 'is passed to wallet service' do
      Worker::DepositCoinAddress.new.process(account_id: account.id)
      expect(subject).to eq address
    end
  end
end
