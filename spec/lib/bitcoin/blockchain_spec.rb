describe Bitcoin::Blockchain do
  context :features do
    it 'defaults' do
      blockchain1 = Bitcoin::Blockchain.new
      expect(blockchain1.features).to eq Bitcoin::Blockchain::DEFAULT_FEATURES
    end

    it 'override defaults' do
      blockchain2 = Bitcoin::Blockchain.new(cash_addr_format: true)
      expect(blockchain2.features[:cash_addr_format]).to be_truthy
    end

    it 'custom feautures' do
      blockchain3 = Bitcoin::Blockchain.new(custom_feature: :custom)
      expect(blockchain3.features.keys).to contain_exactly(*Bitcoin::Blockchain::SUPPORTED_FEATURES)
    end
  end

  context :configure do
    let(:blockchain) { Bitcoin::Blockchain.new }
    it 'default settings' do
      expect(blockchain.settings).to eq({})
    end

    it 'currencies and server configuration' do
      blockchain_currencies = BlockchainCurrency.where.not(blockchain_key: nil).first(2).map(&:to_blockchain_api_settings)
      settings = { server: 'http://user:password@127.0.0.1:18332',
                   currencies: blockchain_currencies,
                   something: :custom }
      blockchain.configure(settings)
      expect(blockchain.settings).to eq(settings.slice(*Peatio::Blockchain::Abstract::SUPPORTED_SETTINGS))
    end
  end

  context :transaction_sources do
    let(:server) { 'http://user:password@127.0.0.1:18332' }
    let(:endpoint) { '127.0.0.1:18332' }
    let(:blockchain) do
      Bitcoin::Blockchain.new.tap {|b| b.configure(server: server)}
    end

    def request_raw_transaction(transaction)
      {
        jsonrpc: '1.0',
        method: :getrawtransaction,
        params: [transaction.hash, 1]
      }.to_json
    end

    context 'transaction 3 vins' do

      let(:transaction_file_name) { 'b3aa85765aa52cf7eb0a7f0eb7ac3447b9b1a82b9323bdd8d73fc305073a3711.json' }
      let(:transaction_data) do
        Rails.root.join('spec', 'resources', 'bitcoin-data', transaction_file_name)
          .yield_self { |file_path| File.open(file_path) }
          .yield_self { |file| JSON.load(file) }
      end

      let(:vin1_transaction_file_name) { 'vin-1ec4bf89b77f0d72ee41f41c97a6d380bd69e0221bf182b993b64bb37d017b57.json' }
      let(:vin1_transaction_data) do
        Rails.root.join('spec', 'resources', 'bitcoin-data', vin1_transaction_file_name)
          .yield_self { |file_path| File.open(file_path) }
          .yield_self { |file| JSON.load(file) }
      end

      let(:vin2_transaction_file_name) { 'vin-8bde1da3d2315e09f910cb9782018fe243740c56cd7ca78a19016b169e74180a.json' }
      let(:vin2_transaction_data) do
        Rails.root.join('spec', 'resources', 'bitcoin-data', vin2_transaction_file_name)
          .yield_self { |file_path| File.open(file_path) }
          .yield_self { |file| JSON.load(file) }
      end

      let(:vin3_transaction_file_name) { 'vin-64a04cad438b64e260bc0b832bde79913d618d3206e834de66bbcb1304629d61.json' }
      let(:vin3_transaction_data) do
        Rails.root.join('spec', 'resources', 'bitcoin-data', vin3_transaction_file_name)
          .yield_self { |file_path| File.open(file_path) }
          .yield_self { |file| JSON.load(file) }
      end

      let(:transaction) { Peatio::Transaction.new(hash: 'b3aa85765aa52cf7eb0a7f0eb7ac3447b9b1a82b9323bdd8d73fc305073a3711') }
      let(:vin1_transaction) { Peatio::Transaction.new(hash: '1ec4bf89b77f0d72ee41f41c97a6d380bd69e0221bf182b993b64bb37d017b57') }
      let(:vin2_transaction) { Peatio::Transaction.new(hash: '8bde1da3d2315e09f910cb9782018fe243740c56cd7ca78a19016b169e74180a') }
      let(:vin3_transaction) { Peatio::Transaction.new(hash: '64a04cad438b64e260bc0b832bde79913d618d3206e834de66bbcb1304629d61') }

      before do
        stub_request(:post, endpoint)
          .with(body: request_raw_transaction(transaction))
          .to_return(body: transaction_data.to_json)

        stub_request(:post, endpoint)
          .with(body: request_raw_transaction(vin1_transaction))
          .to_return(body: vin1_transaction_data.to_json)

        stub_request(:post, endpoint)
          .with(body: request_raw_transaction(vin2_transaction))
          .to_return(body: vin2_transaction_data.to_json)

        stub_request(:post, endpoint)
          .with(body: request_raw_transaction(vin3_transaction))
          .to_return(body: vin3_transaction_data.to_json)
      end

      it do
        addresses = blockchain.transaction_sources(transaction)
        expect(addresses).to eq(['1GsV7tXxXhfdp7kEFoFkgQLUWyv2xgPjnQ'])
      end
    end

    context 'miner transaction' do
      let(:transaction) { Peatio::Transaction.new(hash: '1da4b5a135cc0fee9d3aeb5428a898fd12fe5b1b777fd291dbbdbb72c2da8759') }
      let(:transaction_file_name) { 'miner_transaction.json' }
      let(:transaction_data) do
        Rails.root.join('spec', 'resources', 'bitcoin-data', transaction_file_name)
          .yield_self { |file_path| File.open(file_path) }
          .yield_self { |file| JSON.load(file) }
      end

      before do
        stub_request(:post, endpoint)
          .with(body: request_raw_transaction(transaction))
          .to_return(body: transaction_data.to_json)
      end

      it do
        addresses = blockchain.transaction_sources(transaction)
        expect(addresses).to eq([])
      end
    end
  end

  context :latest_block_number do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:server) { 'http://user:password@127.0.0.1:18332' }
    let(:endpoint) { '127.0.0.1:18332' }
    let(:blockchain) do
      Bitcoin::Blockchain.new.tap {|b| b.configure(server: server)}
    end

    it 'returns latest block number' do
      block_number = 1489174

      stub_request(:post, endpoint)
        .with(body: { jsonrpc: '1.0',
                      method: :getblockcount,
                      params:  [] }.to_json)
        .to_return(body: { result: block_number,
                           error:  nil,
                           id:     nil }.to_json)

      expect(blockchain.latest_block_number).to eq(block_number)
    end

    it 'raises error if there is error in response body' do
      stub_request(:post, endpoint)
        .with(body: { jsonrpc: '1.0',
                      method: :getblockcount,
                      params:  [] }.to_json)
        .to_return(body: { result: nil,
                           error:  { code: -32601, message: 'Method not found' },
                           id:     nil }.to_json)

      expect{ blockchain.latest_block_number }.to raise_error(Peatio::Blockchain::ClientError)
    end
      
    it 'keeps alive' do
      stub_request(:post, endpoint)
          .to_return(body: { result: 1489174,
                             error:  nil,
                             id:     nil }.to_json)
          .with(headers: { 'Connection': 'keep-alive',
                           'Keep-Alive': '30' })

      blockchain.latest_block_number
    end
  end

  context :fetch_block! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:block_file_name) { '1354419-1354420.json' }
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'bitcoin-data', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['result']['height'] }
    let(:latest_block)  { block_data.last['result']['height'] }

    def request_block_hash_body(block_height)
      { jsonrpc: '1.0',
        method: :getblockhash,
        params:  [block_height]
      }.to_json
    end

    def request_block_body(block_hash)
      { jsonrpc: '1.0',
        method:  :getblock,
        params:  [block_hash, 2]
      }.to_json
    end

    before do
      block_data.each do |blk|
        # stub get_block_hash
        stub_request(:post, endpoint)
          .with(body: request_block_hash_body(blk['result']['height']))
          .to_return(body: {result: blk['result']['hash']}.to_json)

        # stub get_block
        stub_request(:post, endpoint)
          .with(body: request_block_body(blk['result']['hash']))
          .to_return(body: blk.to_json)
      end
    end

    let(:currency) do
      Currency.find_by(id: :btc)
    end

    let(:server) { 'http://user:password@127.0.0.1:18332' }
    let(:endpoint) { 'http://127.0.0.1:18332' }
    let(:blockchain) do
      Bitcoin::Blockchain.new.tap { |b| b.configure(server: server, currencies: [currency]) }
    end

    context 'first block' do
      subject { blockchain.fetch_block!(start_block) }

      it 'builds expected number of transactions' do
        expect(subject.count).to eq(14)
      end

      it 'all transactions are valid' do
        expect(subject.all?(&:valid?)).to be_truthy
      end
    end

    context 'last block' do
      subject { blockchain.fetch_block!(latest_block) }

      it 'builds expected number of transactions' do
        expect(subject.count).to eq(20)
      end

      it 'all transactions are valid' do
        expect(subject.all?(&:valid?)).to be_truthy
      end
    end
  end

  context :build_transaction do

    let(:tx_file_name) { '1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22.json' }

    let(:tx_hash) do
      Rails.root.join('spec', 'resources', 'bitcoin-data', tx_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end
    let(:expected_transactions) do
      [{:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
        :txout=>0,
        :to_address=>"mg4KVGerD3rYricWC8CoBaayDp1YCKMfvL",
        :amount=>0.325e0,
        :status=>"success",
        :currency_id=>blockchain_currency.currency_id},
       {:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
        :txout=>1,
        :to_address=>"mqaBwWDjJCE2Egsf6pfysgD5ZBrfsP7NkA",
        :amount=>0.1964466932e2,
        :status=>"success",
        :currency_id=>blockchain_currency.currency_id}]
    end

    let(:blockchain_currency) do
      BlockchainCurrency.find_by(currency_id: :btc)
    end

    let(:blockchain) do
      Bitcoin::Blockchain.new.tap { |b| b.configure(currencies: [blockchain_currency.to_blockchain_api_settings]) }
    end

    it 'builds formatted transactions for passed transaction' do
      expect(blockchain.send(:build_transaction, tx_hash)).to contain_exactly(*expected_transactions)
    end

    context 'multiple currencies' do
      let(:expected_transactions) do
        [{:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
          :txout=>0,
          :to_address=>"mg4KVGerD3rYricWC8CoBaayDp1YCKMfvL",
          :amount=>0.325e0,
          :status=>"success",
          :currency_id=>blockchain_currency1.currency_id},
         {:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
          :txout=>1,
          :to_address=>"mqaBwWDjJCE2Egsf6pfysgD5ZBrfsP7NkA",
          :amount=>0.1964466932e2,
          :status=>"success",
          :currency_id=>blockchain_currency1.currency_id},
         {:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
          :txout=>0,
          :to_address=>"mg4KVGerD3rYricWC8CoBaayDp1YCKMfvL",
          :amount=>0.325e0,
          :status=>"success",
          :currency_id=>blockchain_currency2.currency_id},
         {:hash=>"1858591d8ce638c37d5fcd92b9b33ee96be1b950e593cf0cbf45e6bfb1ad8a22",
          :txout=>1,
          :to_address=>"mqaBwWDjJCE2Egsf6pfysgD5ZBrfsP7NkA",
          :amount=>0.1964466932e2,
          :status=>"success",
          :currency_id=>blockchain_currency2.currency_id}]
      end

      let(:blockchain_currency1) do
        BlockchainCurrency.find_by(currency_id: :btc)
      end

      let(:blockchain_currency2) do
        BlockchainCurrency.find_by(currency_id: :btc)
      end

      let(:blockchain) do
        Bitcoin::Blockchain.new.tap do |b|
          b.configure(currencies: [blockchain_currency1.to_blockchain_api_settings, blockchain_currency2.to_blockchain_api_settings])
        end
      end

      it 'builds formatted transactions for passed transaction per each currency' do
        expect(blockchain.send(:build_transaction, tx_hash)).to contain_exactly(*expected_transactions)
      end
    end

    context 'three vout transaction' do
      let(:tx_file_name) { '1da5cd163a9aaf830093115ac3ac44355e0bcd15afb59af78f84ad4084973ad0.json' }

      let(:expected_transactions) do
        [{:hash=>"1da5cd163a9aaf830093115ac3ac44355e0bcd15afb59af78f84ad4084973ad0",
          :txout=>0,
          :to_address=>"2N5WyM3QT1Kb6fvkSZj3Xvcx2at7Ydm5VmL",
          :amount=>0.1e0,
          :status=>"success",
          :currency_id=>"btc"},
         {:hash=>"1da5cd163a9aaf830093115ac3ac44355e0bcd15afb59af78f84ad4084973ad0",
          :txout=>1,
          :to_address=>"2MzDFuDK9ZEEiRsuCDFkPdeHQLGvwbC9ufG",
          :amount=>0.2e0,
          :status=>"success",
          :currency_id=>"btc"},
         {:hash=>"1da5cd163a9aaf830093115ac3ac44355e0bcd15afb59af78f84ad4084973ad0",
          :txout=>2,
          :to_address=>"2MuvCKKi1MzGtvZqvcbqn5twjA2v5XLaTWe",
          :amount=>0.11749604e0,
          :status=>"success",
          :currency_id=>"btc"}]
      end

      it 'builds formatted transactions for each vout' do
        expect(blockchain.send(:build_transaction, tx_hash)).to contain_exactly(*expected_transactions)
      end
    end
  end

  context :load_balance_of_address! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:server) { 'http://user:password@127.0.0.1:18332' }
    let(:blockchain) do
      Bitcoin::Blockchain.new.tap {|b| b.configure(server: server)}
    end


    let(:response) do
      [
        [
          [
            "mh2e7YHio7fTjLXHZ3KRXDfU52RbwQbhtK",
            0,
            ""
          ]
        ],
        [
          [
            "mkuYucVhRQDiSHszbZ9M7d7vygKymyZ549",
            0.14458097,
            "my_imported_address_from_electrum"
          ],
          [
            "mpD544rTPbRNDr9yzK9MTGS4ckfVxUNY42",
            0.24997197,
            "imported_address_from_bitgo"
          ]
        ]
      ]
    end

    before do
      stub_request(:post, 'http://127.0.0.1:18332')
        .with(body: { jsonrpc: '1.0',
                      method: :listaddressgroupings,
                      params: [] }.to_json)
        .to_return(body: { result: response,
                           error:  nil,
                           id:     nil }.to_json)
    end

    context 'address with balance is defined' do
      it 'requests rpc listaddressgroupings and finds address balance' do
        address = 'mpD544rTPbRNDr9yzK9MTGS4ckfVxUNY42'

        result = blockchain.load_balance_of_address!(address, :btc)
        expect(result).to be_a(BigDecimal)
        expect(result).to eq('0.24997197'.to_d)
      end

      it 'requests rpc listaddressgroupings and finds address with zero balance' do
        address = 'mh2e7YHio7fTjLXHZ3KRXDfU52RbwQbhtK'

        result = blockchain.load_balance_of_address!(address, :btc)
        expect(result).to be_a(BigDecimal)
        expect(result).to eq('0'.to_d)
      end
    end

    context 'address is not defined' do
      it 'requests rpc listaddressgroupings and do not find address' do
        address = '1PoxQx6Pk5NwWN1yyBx2jifFvS9eJAksdf'
        expect{ blockchain.load_balance_of_address!(address, :btc)}.to raise_error(Peatio::Blockchain::UnavailableAddressBalanceError)
      end
    end

    context 'client error is raised' do
      before do
        stub_request(:post, 'http://127.0.0.1:18332')
          .with(body: { jsonrpc: '1.0',
                        method: :listaddressgroupings,
                        params: [] }.to_json)
          .to_return(body: { result: nil,
                             error:  { code: -32601, message: 'Method not found' },
                             id:     nil }.to_json)
      end

      it 'raise wrapped client error' do
        expect{ blockchain.load_balance_of_address!('anything', :btc)}.to raise_error(Peatio::Blockchain::ClientError)
      end
    end
  end
end
