describe CoinAPI::ETH do
  let(:client) { CoinAPI[:eth] }

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe '#create_address!' do
    subject { client.create_address! }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'personal_newAccount',
        params:  %w[ pass@word ]
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  '0x42eb768f2244c8811c63729a21a3569731535f06'
      }.to_json
    end

    before do
      Passgen.stubs(:generate).returns('pass@word')
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it { is_expected.to eq(address: '0x42eb768f2244c8811c63729a21a3569731535f06', secret: 'pass@word') }
  end

  describe '#load_balance!' do
    subject(:load_balance!) { client.load_balance! }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_getBalance',
        params:  %w[ 0xb3b89717c0cbbce35972d8a8f75bc9cd20748a91 latest ]
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  '0x28d2360052d640e0'
      }.to_json
    end

    before do
      create(:payment_address, currency: client.currency, address: '0xb3b89717c0cbbce35972d8a8f75bc9cd20748a91')
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it 'returns balance' do
      expect(load_balance!).to eq('2.941472881644028128'.to_d)
    end
  end

  describe '#inspect_address!' do
    context 'valid address' do
      let(:address) { '0x42eb768f2244c8811c63729a21a3569731535f06' }
      subject { client.inspect_address!(address) }
      it { is_expected.to eq({ address: address, is_valid: true }) }
    end

    context 'invalid address' do
      let(:address) { '0x729a21a3569731535f06' }
      subject { client.inspect_address!(address) }
      it { is_expected.to eq({ address: address, is_valid: false }) }
    end
  end

  describe '#each_deposit!' do
    subject { client.each_deposit! }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_getBlockByNumber',
        params:  ['0x1', true]
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  {
          number:           '0x1b4',
          hash:             '0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331',
          parentHash:       '0x9646252be9520f6e71339a8df9c55e4d7619deeb018d2a3f2d21fc165dde5eb5',
          nonce:            '0xe04d296d2460cfb8472af2c5fd05b5a214109c25688d3704aed5484f9a7792f2',
          sha3Uncles:       '0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347',
          logsBloom:        '0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331',
          transactionsRoot: '0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421',
          stateRoot:        '0xd5855eb08b3387c0af375e9cdb6acfc05eb8f519e419b874b6ff2ffda7ed1dff',
          miner:            '0x4e65fda2159562a496f9f3522f89122a3088497a',
          difficulty:       '0x027f07',
          totalDifficulty:  '0x027f07',
          extraData:        '0x0000000000000000000000000000000000000000000000000000000000000000',
          size:             '0x027f07',
          gasLimit:         '0x9f759',
          gasUsed:          '0x9f759',
          timestamp:        '0x54e34e8e',
          uncles:           ['0xb903239f8543d04b5dc1ba6579132b143087c68db1b2168786408fcbce568238'],
          transactions:     [{ hash:             '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b',
                               nonce:            '0x',
                               blockHash:        '0xbeab0aa2411b7ab17f30a99d3cb9c6ef2fc5426d6ad6fd9e2a26a6aed1d1055b',
                               blockNumber:      '0x1',
                               transactionIndex: '0x1',
                               from:             '0x407d73d8a49eeb85d32cf465507dd71d507100c1',
                               to:               '0x85h43d8a49eeb85d32cf465507dd71d507100c1',
                               value:            '0x7f110',
                               gas:              '0x7f110',
                               gasPrice:         '0x09184e72a000',
                               input:            '0x603880600c6000396000f300603880600c6000396000f3603880600c6000396000f360'
                            }]
        }
      }.to_json
    end

    before do
      client.expects(:latest_block_number).returns(1)
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it do
      is_expected.to eq([{
        id:            '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b',
        confirmations: 0,
        received_at:   Time.at(0x54e34e8e),
        entries:       [{ address: '0x85h43d8a49eeb85d32cf465507dd71d507100c1',
                          amount:  0x7f110.to_d / client.currency.base_factor }]
      }])
    end
  end

  describe '#load_deposit!' do
    let(:hash) { '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b' }
    subject { client.load_deposit!(hash) }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_getTransactionByHash',
        params:  [hash]
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  { hash:             '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b',
                   nonce:            '0x',
                   blockHash:        '0xbeab0aa2411b7ab17f30a99d3cb9c6ef2fc5426d6ad6fd9e2a26a6aed1d1055b',
                   blockNumber:      '0x1',
                   transactionIndex: '0x1',
                   from:             '0x407d73d8a49eeb85d32cf465507dd71d507100c1',
                   to:               '0x85h43d8a49eeb85d32cf465507dd71d507100c1',
                   value:            '0x7f110',
                   gas:              '0x7f110',
                   gasPrice:         '0x09184e72a000',
                   input:            '0x603880600c6000396000f300603880600c6000396000f3603880600c6000396000f360' }
      }.to_json
    end

    before do
      client.expects(:block_information).returns('timestamp' => '0x54e34e8e')
      client.expects(:latest_block_number).returns(1)
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it do
      is_expected.to eq({
        id:            '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b',
        confirmations: 0,
        received_at:   Time.at(0x54e34e8e),
        entries:       [{ address: '0x85h43d8a49eeb85d32cf465507dd71d507100c1',
                          amount:  0x7f110.to_d / client.currency.base_factor }]
      })
    end
  end

  describe 'create_withdrawal!' do
    let(:issuer) { { address: '0x407d73d8a49eeb85d32cf465507dd71d507100c1', secret: 'pass@word' } }
    let(:recipient) { { address: '0x85h43d8a49eeb85d32cf465507dd71d507100c1' } }
    subject { client.create_withdrawal!(issuer, recipient, 10, gas_limit: 21_000) }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_sendTransaction',
        params:  [{
          from:  issuer[:address],
          to:    recipient[:address],
          value: '0x8ac7230489e80000',
          gas:   '0x5208'
        }]
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b'
      }.to_json
    end

    before do
      client.expects(:permit_transaction)
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it { is_expected.to eq('0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b') }
  end
end
