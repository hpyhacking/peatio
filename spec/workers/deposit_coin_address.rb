# encoding: UTF-8
# frozen_string_literal: true

describe Worker::DepositCoinAddress do
  describe 'BitGo label address' do
    let(:member) { create(:member, :barong) }
    let(:account) { member.ac(:btc) }
    let(:address) { Faker::Bitcoin.address }
    subject { account.payment_address.address }
    before do
      CoinAPI::BTC.any_instance
                  .expects(:create_address!)
                  .with(address_id: nil, label: member.uid)
                  .returns(address: address)
    end

    it 'is passed to currency API' do
      Worker::DepositCoinAddress.new.process(account_id: account.id)
      expect(subject).to eq address
    end
  end
end