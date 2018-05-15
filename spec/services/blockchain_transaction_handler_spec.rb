# encoding: UTF-8
# frozen_string_literal: true

describe Services::BlockchainTransactionHandler do
  subject { Services::BlockchainTransactionHandler.new(currency) }

  context 'sendmany Bitcoin transaction' do
    let(:currency) { Currency.find_by_code!(:btc) }
    let(:account) { create_account(:btc, balance: 0, locked: 0) }
    let!(:address) { create(:payment_address, account: account, currency: currency, address: '2N5hGKgd4HvXEpUCvMqwgZNSAFU5BQhpZSw') }
    let :tx do
      { id:            'cef78e917a5e920ea3f458688940eda9462d47f84631030a09e2a2174d3cfb6f',
        confirmations: 3,
        entries:       [{ amount: '0.55998878'.to_d, address: '2N5hGKgd4HvXEpUCvMqwgZNSAFU5BQhpZSw' },
                        { amount: '0.09'.to_d,       address: '2NExB34JEV7VqphrurPciYemZDsveP9MPxo' }],
        received_at:   Time.parse('2018-05-04 10:04:10 UTC') }
    end

    before do
      AMQPQueue.expects(:enqueue)
               .with(:deposit_coin, { txid: 'cef78e917a5e920ea3f458688940eda9462d47f84631030a09e2a2174d3cfb6f', currency: 'btc' })
               .once
    end

    it 'handles' do
      expect(account.balance + account.locked).to eq 0
      subject.call(tx)
    end
  end
end
