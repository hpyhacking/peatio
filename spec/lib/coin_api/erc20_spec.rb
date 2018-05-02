describe CoinAPI::ERC20 do
  let(:client) { CoinAPI[:trst] }

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
        method:  'eth_call',
        params:  [{ to:   '0x87099add3bcc0821b5b151307c147215f839a110',
                    data: '0x' + '70a0823100000000000000000000000042eb768f2244c8811c63729a21a3569731535f06'
                  }, 'latest']
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  '0x0000000000000000000000000000000000000000000000000000000000000000'
      }.to_json
    end

    before do
      create(:payment_address, currency: client.currency, address: '0x42eb768f2244c8811c63729a21a3569731535f06')
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end
    it 'returns balance' do
      expect(load_balance!).to eq('0.0'.to_d)
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
      '{"jsonrpc":"2.0","id":1,"result":{"difficulty":"0x2","extraData":"0xd883010805846765746888676f312e31302e31856c696e757800000000000000b41a6a99df5aca5d4c6cb3feaf43409b3ce3f17b469cd2a5ded87d7a2a83522c05bf254179df7e8f9a1aa71358bc1403a10c8db3845733abff15442b09efcdf900","gasLimit":"0x7260f2","gasUsed":"0x15f2ce","hash":"0x1f605e0ddd50a6c8f8b924ebb3556e4a5b143954e9595ea7efd374d4f825a94d","logsBloom":"0x0000004002030008000080000000600002400808500000800000080000000042009000002002200001008418000000000800000000010020000000000820000204000000004000004000000a00008042000a0000018000040004080008005101000000000200000000400000010000001000000410101400000000101040020080200800010000000800000000400010000000c0046000000000008011000010220400000010200019400000020010002000000000400080000110080000000000000202204c00000040003400010400000002810000020302200000000000000011000000000400000000000109000022800000100008000003004800000000","miner":"0x0000000000000000000000000000000000000000","mixHash":"0x0000000000000000000000000000000000000000000000000000000000000000","nonce":"0x0000000000000000","number":"0x21ac34","parentHash":"0xff8607ef8e2e5e287cd28a84f41f12889edcf72daf298d1790fce36f0868d5fc","receiptsRoot":"0x7d6c0e9fc394c54a51dc528269063a18dcd76c3949ca4321ce5f9f4ba1905eb7","sha3Uncles":"0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347","size":"0x140b","stateRoot":"0xf3502f6b3cd4576f2586e8926dcc1aed1a72b00a13ab3e661aef7ec385d96e1d","timestamp":"0x5ae845b7","totalDifficulty":"0x3eef05","transactions":[{"blockHash":"0x1f605e0ddd50a6c8f8b924ebb3556e4a5b143954e9595ea7efd374d4f825a94d","blockNumber":"0x21ac34","from":"0x36467882847a574d0336195d21355f310da7bb6a","gas":"0x12db1","gasPrice":"0x77359400","hash":"0xd5b520b69fd90a2eb59be18ab16a8db3a91008cd658e8b2417c943b05e4619ba","input":"0xa9059cbb0000000000000000000000002668574506dd5dbcd927db89b1b2f0c437175c78000000000000000000000000000000000000000000000000000000000007a120","nonce":"0x5","to":"0x87099add3bcc0821b5b151307c147215f839a110","transactionIndex":"0xf","value":"0x0","v":"0x2b","r":"0xa3ec113fddb3981271e396c7062abff4da46ecdd5defc700bf985dd5e4b1a5d","s":"0x21e19ba6ffd103e8d6808b1156f25e5366d14e45893287463a0868dbd2979a3b"}],"transactionsRoot":"0x2d4de232342937efa4a7d375d8ba5f6c5fd4d49e50929b532c7eb661472bef59","uncles":[]}}'
    end

    before do
      client.expects(:latest_block_number).returns(1)
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it do
      is_expected.to eq([{
                           id:            '0xd5b520b69fd90a2eb59be18ab16a8db3a91008cd658e8b2417c943b05e4619ba',
                           confirmations: 0,
                           received_at:   Time.at(0x5ae845b7),
                           entries:       [{ address: '0x2668574506dd5dbcd927db89b1b2f0c437175c78',
                                             amount:  '0.5'.to_d }]
                         }])
    end
  end

  describe '#load_deposit!' do
    subject { client.load_deposit!(hash) }

    let(:hash) { '0xc496f09c00916b4e40f2ae6e05d3c8927689e4b447e914064fb9213c380bf965' }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_getTransactionReceipt',
        params:  [hash]
      }.to_json
    end

    let :response_body do
      '{"jsonrpc":"2.0","id":1,"result":{"blockHash":"0x2327990cda5c1ea2968b7e9b8913fae81efbd36a5aa1789d3ba5dfbbc1548f76","blockNumber":"0x20ccf8","cumulativeGasUsed":"0xc8e1","from":"0xdd61c7d5a1213af4a7b589f6e557cce3fcc0cfbb","gasUsed":"0xc8e1","logs":[{"address":"0x87099add3bcc0821b5b151307c147215f839a110","topics":["0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef","0x000000000000000000000000dd61c7d5a1213af4a7b589f6e557cce3fcc0cfbb","0x000000000000000000000000785529cc54014e00bb3bbfe4f18cec960e72a401"],"data":"0x00000000000000000000000000000000000000000000000000000000000f4240","blockNumber":"0x20ccf8","transactionHash":"0xc496f09c00916b4e40f2ae6e05d3c8927689e4b447e914064fb9213c380bf965","transactionIndex":"0x0","blockHash":"0x2327990cda5c1ea2968b7e9b8913fae81efbd36a5aa1789d3ba5dfbbc1548f76","logIndex":"0x0","removed":false}],"logsBloom":"0x00000000000000004000000000000000000000000000000000001000000000000010000000000000000000000000000000000000000000000200000000000000000000000000000000000008000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000010000000000000000000000000000000000200000000000000000000000000000000000000000200000000000000002000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","status":"0x1","to":"0x87099add3bcc0821b5b151307c147215f839a110","transactionHash":"0xc496f09c00916b4e40f2ae6e05d3c8927689e4b447e914064fb9213c380bf965","transactionIndex":"0x0"}}'
    end

    before do
      client.expects(:latest_block_number).returns(2166994)
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it do
      is_expected.to eq \
        id:            '0xc496f09c00916b4e40f2ae6e05d3c8927689e4b447e914064fb9213c380bf965',
        confirmations: 17370,
        entries:       [{ amount: '1.0'.to_d, address: '0x785529cc54014e00bb3bbfe4f18cec960e72a401' }]
    end
  end

  describe 'create_withdrawal!' do
    subject { client.create_withdrawal!(issuer, recipient, 10) }

    let(:issuer) { { address: '0x785529cc54014e00bb3bbfe4f18cec960e72a401', secret: 'guz@?I0cYav)9b0bk1#(%Tol#TtY5hOLYg7NWq+G#6X%1fTqXz!h4Egjl84HE3ws' } }
    let(:recipient) { { address: '0xDD61C7D5a1213AF4A7b589F6E557cCe3fCC0cfbB' } }

    let :request_body do
      { jsonrpc: '2.0',
        id:      1,
        method:  'eth_sendTransaction',
        params:  [from: '0x785529cc54014e00bb3bbfe4f18cec960e72a401',
                  to:   '0x87099add3bcc0821b5b151307c147215f839a110',
                  data: '0xa9059cbb000000000000000000000000dd61c7d5a1213af4a7b589f6e557cce3fcc0cfbb0000000000000000000000000000000000000000000000000000000000989680']
      }.to_json
    end

    let :response_body do
      { jsonrpc: '2.0',
        id:      1,
        result:  '0x3d26f9395f564eeb267188b97443b76967a88db62cbd91dec328a31145dde483'
      }.to_json
    end

    before do
      client.expects(:permit_transaction)
      stub_request(:post, 'http://127.0.0.1:8545/').with(body: request_body).to_return(body: response_body)
    end

    it { is_expected.to eq('0x3d26f9395f564eeb267188b97443b76967a88db62cbd91dec328a31145dde483') }
  end
end
