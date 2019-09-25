# encoding: UTF-8
# frozen_string_literal: true

describe Workers::AMQP::DepositCoinAddress do
  let(:member) { create(:member, :barong) }
  let(:account) { member.ac(:btc) }
  let(:address) { Faker::Blockchain::Bitcoin.address }
  let(:secret) { PasswordGenerator.generate(64) }
  let(:wallet) { Wallet.deposit.find_by(blockchain_key: 'btc-testnet') }
  let(:payment_address) { account.payment_address }
  let(:create_address_result) do
    { address: address,
      secret: secret,
      details: {label: 'new-label'} }
  end

  subject { account.payment_address.address }

  it 'raise error on databse connection error' do
    Account.stubs(:find_by_id).raises(Mysql2::Error::ConnectionError.new(''))
    expect {
      Workers::AMQP::DepositCoinAddress.new.process(account_id: account.id)
    }.to raise_error Mysql2::Error::ConnectionError
  end

  context 'wallet service' do
    before do
      WalletService.any_instance
                    .expects(:create_address!)
                    .returns(create_address_result)
    end

    it 'is passed to wallet service' do
      Workers::AMQP::DepositCoinAddress.new.process(account_id: account.id)
      expect(subject).to eq address
      payment_address.reload
      expect(payment_address.as_json
               .deep_symbolize_keys
               .slice(:address, :secret, :details)).to eq(create_address_result)
    end

    context 'empty address details' do
      let(:create_address_result) do
        { address: address,
          secret: secret }
      end

      it 'is passed to wallet service' do
        Workers::AMQP::DepositCoinAddress.new.process(account_id: account.id)
        expect(subject).to eq address
        payment_address.reload
        expect(payment_address.as_json
                 .deep_symbolize_keys
                 .slice(:address, :secret, :details)).to eq(create_address_result.merge(details: {}))
      end
    end
  end
end
