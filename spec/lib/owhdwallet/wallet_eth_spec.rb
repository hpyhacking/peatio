describe OWHDWallet::WalletETH do
  let(:wallet) { OWHDWallet::WalletETH.new }
  let(:infura_url) { 'https://rinkeby.infura.io/v3/08825a23f9454f998e6e7ba60bb6f023' }
  let(:hdwallet_url) { 'http://127.0.0.1:8000/api/v2/hdwallet' }
  let(:hdwallet_wallet_new_url) { hdwallet_url + '/wallet/new' }
  let(:hdwallet_wallet_balance_url) { hdwallet_url + '/wallet/balance' }

  context :configure do
    let(:settings) { { wallet: {}, currency: {} } }
    it 'requires wallet' do
      expect { wallet.configure(settings.except(:wallet)) }.to raise_error(Peatio::Wallet::MissingSettingError)

      expect { wallet.configure(settings) }.to_not raise_error
    end

    it 'requires currency' do
      expect { wallet.configure(settings.except(:currency)) }.to raise_error(Peatio::Wallet::MissingSettingError)

      expect { wallet.configure(settings) }.to_not raise_error
    end

    it 'sets settings attribute' do
      wallet.configure(settings)
      expect(wallet.settings).to eq(settings.slice(*Ethereum::Eth::Wallet::SUPPORTED_SETTINGS))
    end
  end

  context :create_address! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:eth) do
      BlockchainCurrency.find_by(currency_id: :eth)
    end

    let(:settings) do
      {
        wallet: {
           address: 'something',
           uri:     hdwallet_url
        },
        currency: eth.to_blockchain_api_settings
      }
    end

    let(:uri_result) do
      {
        address: '0xa57e810B5f96b049F9030AfE1f1004630818EC72',
        coin_type: 'eth',
        passphrase: 'vault:v1:4vDyZo/zxr5C91vsVFxohE7HiX/rsQ==',
        wallet_index: 2
      }
    end

    before do
      wallet.configure(settings)
    end

    it 'should create an address' do
      stub_request(:post, hdwallet_wallet_new_url)
        .with(body: {coin_type: 'eth'}.to_json)
        .to_return(body: uri_result.to_json)

      result = wallet.create_address!(uid: 'UID123')

      expect(result.as_json.symbolize_keys).to eq(address: uri_result[:address], secret: uri_result[:passphrase],
                                                  details: uri_result.except(:address, :passphrase).with_indifferent_access)
    end

    context 'erc-20' do
      let(:trst) do
        BlockchainCurrency.find_by(currency_id: :trst)
      end

      let(:settings) do
        {
          wallet: {
            address: 'something',
            uri:     hdwallet_url
          },
          currency: trst.to_blockchain_api_settings
        }
      end

      before do
        wallet.configure(settings)
      end

      it 'should create address for erc-20 coin' do
        stub_request(:post, hdwallet_wallet_new_url)
          .with(body: {coin_type: 'eth'}.to_json)
          .to_return(body: uri_result.to_json)

        result = wallet.create_address!(uid: 'UID123')

        expect(result.as_json.symbolize_keys).to eq(address: uri_result[:address], secret: uri_result[:passphrase],
                                                    details: uri_result.except(:address, :passphrase).with_indifferent_access)
      end
    end

    it 'should return error' do
      stub_request(:post, hdwallet_wallet_new_url)
        .with(body: {coin_type: 'eth'}.to_json)
        .to_return(status: 422, body: {'error': 'wallet sealed'}.to_json)

      expect { wallet.create_address!(uid: 'UID123') }.to raise_error(Peatio::Wallet::ClientError)
    end
  end

  context :prepare_deposit_collection! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:fee_wallet) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :fee) }

    let(:trst) do
      BlockchainCurrency.find_by(currency_id: :trst)
    end

    let(:spread_deposit) do
      [{ to_address: 'fake-hot',
         amount: '2.0',
         currency_id: trst.id },
       { to_address: 'fake-hot',
         amount: '2.0',
         currency_id: trst.id }]
    end

    let(:settings) do
      {
        wallet: {
          address: fee_wallet.address,
          uri: hdwallet_url,
          gateway_url: infura_url,
          wallet_index: 1,
          secret: 'changeme'
        },
        currency: trst.to_blockchain_api_settings
      }
    end

    let(:request_params) do
      {
        coin_type:    'eth',
        gas_limit:    trst.options.fetch('gas_limit'),
        gas_speed:    'standard',
        spread_size:  spread_deposit.size,
        to:           '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
        gateway_url:  infura_url,
        wallet_index: 1,
        passphrase:   'changeme'
      }
    end

    let(:response) do
      {
        tx: '0xab6ada9608f4cebf799ee8be20fe3fb84b0d08efcdb0d962df45d6fce70cb017',
        gas_price: 1000000000
      }
    end

    before do
      wallet.configure(settings)
    end

    let(:transaction) do
      Peatio::Transaction.new(amount: 1.1.to_d, to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa')
    end

    it do
      stub_request(:post, hdwallet_url + '/tx/before_collect')
        .with(body: request_params.to_json)
        .to_return(body: response.to_json)

      result = wallet.prepare_deposit_collection!(transaction, spread_deposit, trst.to_blockchain_api_settings)
      expect(result.first.as_json.symbolize_keys).to eq(amount: '1.1',
                                                        currency_id: 'eth',
                                                        to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
                                                        hash: '0xab6ada9608f4cebf799ee8be20fe3fb84b0d08efcdb0d962df45d6fce70cb017',
                                                        status: 'pending',
                                                        options: {"gas_limit"=>90000, "gas_price"=>1000000000})
    end

    context 'erc20_contract_address is not configured properly in currency' do
      it 'returns empty array' do
        currency = trst.to_blockchain_api_settings.deep_dup
        currency[:options].delete(:erc20_contract_address)
        expect(wallet.prepare_deposit_collection!(transaction, spread_deposit, currency)).to eq []
      end
    end
  end

  context :create_transaction! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:eth) do
      BlockchainCurrency.find_by(currency_id: :eth)
    end

    let(:trst) do
      BlockchainCurrency.find_by(currency_id: :trst)
    end

    let(:btc) do
      BlockchainCurrency.find_by(currency_id: :btc)
    end

    let(:deposit_wallet_eth) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :deposit) }
    let(:hot_wallet_eth) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :hot) }
    let(:fee_wallet) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :fee) }
    let(:deposit_wallet_trst) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :deposit) }
    let(:hot_wallet_trst) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :hot) }

    let(:transaction) do
      Peatio::Transaction.new(amount: 1.1.to_d, to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa')
    end

    context 'eth transaction' do
      let(:settings) do
        {
          wallet: {
            settings:     deposit_wallet_eth.settings,
            uri:          hdwallet_url,
            address:      deposit_wallet_eth.address,
            secret:       'changeme',
            wallet_index: 1,
            gateway_url:  infura_url,
          },
          currency: eth.to_blockchain_api_settings
        }
      end

      before do
        wallet.configure(settings)
      end

      let(:uri_result) do
        {
          'tx': '0xa56316b637a94c4cc0331c73ef26389d6c097506d581073f927275e7a6ece0bc'
        }
      end

      let(:request_params) do
        {
          coin_type:    'eth',
          to:           transaction.to_address,
          amount:       (transaction.amount.to_d * eth.base_factor).to_i,
          gateway_url:  infura_url,
          wallet_index: 1,
          passphrase:   'changeme',
          gas_speed:    'standard',
          subtract_fee: false,
          gas_limit:    eth.options['gas_limit'],
        }
      end

      it 'should create transaction' do
        stub_request(:post, hdwallet_url + '/tx/send')
          .with(body: request_params.to_json)
          .to_return(body: uri_result.to_json)

        result = wallet.create_transaction!(transaction)
        expect(result.as_json.symbolize_keys).to eq(amount: 1.1.to_s,
                                                    to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
                                                    hash: '0xa56316b637a94c4cc0331c73ef26389d6c097506d581073f927275e7a6ece0bc',
                                                    status: 'pending')
      end
    end

    context 'erc20 transaction' do
      let(:settings) do
        {
          wallet: {
            settings:     deposit_wallet_trst.settings,
            uri:          hdwallet_url,
            address:      deposit_wallet_trst.address,
            secret:       'changeme',
            wallet_index: 1,
            gateway_url:  infura_url,
          },
          currency: trst.to_blockchain_api_settings
        }
      end

      before do
        wallet.configure(settings)
      end

      let(:uri_result) do
        {
          'tx': '0xa56316b637a94c4cc0331c73ef26389d6c097506d581073f927275e7a6ece0bc'
        }
      end

      let(:request_params) do
        {
          coin_type:        'eth',
          to:               transaction.to_address,
          amount:           (transaction.amount.to_d * trst.base_factor).to_i,
          gateway_url:      infura_url,
          wallet_index:     1,
          passphrase:       'changeme',
          gas_speed:        'standard',
          subtract_fee:     false,
          contract_address: trst.options["erc20_contract_address"],
          gas_limit:        trst.options['gas_limit']
        }
      end

      it 'should create transaction' do
        stub_request(:post, hdwallet_url + '/tx/send')
          .with(body: request_params.to_json)
          .to_return(body: uri_result.to_json)

        result = wallet.create_transaction!(transaction)
        expect(result.as_json.symbolize_keys).to eq(amount: 1.1.to_s,
                                                    to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
                                                    hash: '0xa56316b637a94c4cc0331c73ef26389d6c097506d581073f927275e7a6ece0bc',
                                                    status: 'pending')
      end
    end
  end

  context :load_balance! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:eth) do
      BlockchainCurrency.find_by(currency_id: :eth)
    end

    let(:trst) do
      BlockchainCurrency.find_by(currency_id: :trst)
    end

    context 'eth load_balance' do
      let(:settings) do
        {
          wallet: {
            address:     'something',
            uri:         hdwallet_url,
            gateway_url: infura_url
          },
          currency: eth.to_blockchain_api_settings
        }
      end

      before do
        wallet.configure(settings)
      end

      let(:uri_result) do
        {
          'balance': 5000000000000000000
        }
      end

      let(:request_params) do
        {
          coin_type:   'eth',
          gateway_url: infura_url,
          address:     'something'
        }
      end

      it 'should return wallet balance' do
        stub_request(:post, hdwallet_wallet_balance_url)
          .with(body: request_params.to_json)
          .to_return(body: uri_result.to_json)

        wallet.configure(settings)
        result = wallet.load_balance!
        expect(result).to be_a(BigDecimal)
        expect(result).to eq('5'.to_d)
      end
    end

    context 'erc-20 load balance' do
      let(:settings) do
        {
          wallet:
            { address:     'something',
              uri:          hdwallet_url,
              gateway_url:  infura_url},
          currency: trst.to_blockchain_api_settings
        }
      end

      before do
        wallet.configure(settings)
      end

      let(:request_params) do
        {
          coin_type:        'eth',
          gateway_url:      infura_url,
          address:          'something',
          contract_address: trst.options['erc20_contract_address']
        }
      end

      let(:uri_result) do
        {
          'balance': 100000
        }
      end

      it 'should return wallet balance' do
        stub_request(:post, hdwallet_wallet_balance_url)
            .with(body: request_params.to_json)
            .to_return(body: uri_result.to_json)

        wallet.configure(settings)
        result = wallet.load_balance!
        expect(result).to be_a(BigDecimal)
        expect(result).to eq('0.1'.to_d)
      end
    end
  end
end
