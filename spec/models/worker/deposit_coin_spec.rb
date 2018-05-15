# encoding: UTF-8
# frozen_string_literal: true

describe Worker::DepositCoin do
  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  context 'sendmany transaction' do
    let(:worker) { Worker::DepositCoin.new }

    let :payload do
      { 'txid'     => '1a33b61174e5c52c189af4169b6919d059a0024ee6526326961fe6dd8af2e260',
        'currency' => 'btc' }
    end

    let :request_body do
      { jsonrpc: '1.0',
        method:  'gettransaction',
        params:  ['1a33b61174e5c52c189af4169b6919d059a0024ee6526326961fe6dd8af2e260']
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  { amount:          0.2,
                   confirmations:   39,
                   blockhash:       '0000000000d744827317b3f679c52d0090243a13153c6082e0e65cb83fa1193d',
                   blockindex:      1,
                   blocktime:       1_412_317_163,
                   txid:            '1a33b61174e5c52c189af4169b6919d059a0024ee6526326961fe6dd8af2e260',
                   walletconflicts: [],
                   time:            1_412_317_158,
                   timereceived:    1_412_317_158,
                   hex:             '',
                   details:         [{ account:  'payment',
                                       address:  'mov9LqpntN18cuyzUDBoaS8vPY8pF421Y3',
                                       category: 'receive',
                                       amount:   0.1 },
                                     { account:  'payment',
                                       address:  'mqRtfJSdgrbbgMPasq4j3br1G4h3AoJ4hE',
                                       category: 'receive',
                                       amount:   0.1 }] }
      }.to_json
    end

    before do
      create(:btc_payment_address, address: 'mov9LqpntN18cuyzUDBoaS8vPY8pF421Y3')
      create(:btc_payment_address, address: 'mqRtfJSdgrbbgMPasq4j3br1G4h3AoJ4hE')
      stub_request(:post, 'http://127.0.0.1:18332/').with(body: request_body).to_return(body: response_body)
    end

    it 'creates 2 deposits' do
      expect {
        worker.process(payload)
      }.to change(Deposit, :count).by(2)
    end

    context 'sendmany transaction with addresses not belonging to Peatio' do
      before do
        response_body[:result][:details] << { account:  'payment',
                                              address:  '2NExB34JEV7VqphrurPciYemZDsveP9MPxo',
                                              category: 'receive',
                                              amount:   10 }
      end
    end
  end
end
