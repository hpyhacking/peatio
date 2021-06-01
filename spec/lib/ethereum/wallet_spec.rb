describe Ethereum::Eth::Wallet do
  let(:wallet) { Ethereum::Eth::Wallet.new }

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

    let(:uri) { 'http://127.0.0.1:8545' }
    let(:uri_with_path) { 'http://127.0.0.1:8545/path/extra' }

    let(:settings) do
      {
        wallet:
          { address: 'something',
            uri: uri },
        currency: {}
      }
    end

    before do
      PasswordGenerator.stubs(:generate).returns('pass@word')
      wallet.configure(settings)
    end

    it 'request rpc and creates new address' do
      address = '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa'
      stub_request(:post, uri)
        .with(body: { jsonrpc: '2.0',
                      id: 1,
                      method: :personal_newAccount,
                      params: ['pass@word'] }.to_json)
        .to_return(body: { jsonrpc: '2.0',
                           result: address,
                           id: 1 }.to_json)

      result = wallet.create_address!(uid: 'UID123')
      expect(result.as_json.symbolize_keys).to eq(address: address, secret: 'pass@word')
    end

    it 'works with wallet path' do
      wallet.configure({
                         wallet:
                           { address: 'something',
                             uri: uri_with_path },
                         currency: {}
                       })
      address = '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa'
      stub_request(:post, uri_with_path)
        .with(body: { jsonrpc: '2.0',
                      id: 1,
                      method: :personal_newAccount,
                      params: ['pass@word'] }.to_json)
        .to_return(body: { jsonrpc: '2.0',
                           result: address,
                           id: 1 }.to_json)

      result = wallet.create_address!(uid: 'UID123')
      expect(result.as_json.symbolize_keys).to eq(address: address, secret: 'pass@word')
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

    let(:ring) do
      BlockchainCurrency.find_by(currency_id: :ring)
    end

    let(:deposit_wallet_eth) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :deposit) }
    let(:hot_wallet_eth) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :hot) }
    let(:fee_wallet) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :fee) }
    let(:deposit_wallet_trst) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :deposit) }
    let(:hot_wallet_trst) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :hot) }

    let(:uri) { 'http://127.0.0.1:8545' }

    let(:transaction) do
      Peatio::Transaction.new(amount: 1.1.to_d, to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa')
    end

    context 'eth transaction with subtract fees' do
      let(:value) { 1_099_979_000_000_000_000 }

      let(:gas_limit) { 21_000 }
      let(:gas_price) { 1_000_000_000 }
      let(:gas_price_hex) { '0x' + gas_price.to_s(16) }

      let(:request_body) do
        { jsonrpc: '2.0',
          id: 2,
          method: :personal_sendTransaction,
          params: [{
            from: deposit_wallet_eth.address.downcase,
            to: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
            value: '0x' + (value.to_s 16),
            gas: '0x' + (gas_limit.to_s 16),
            gasPrice: gas_price_hex
          }, 'changeme'] }
      end

      let(:eth_GasPrice) do
        {
          "jsonrpc": '2.0',
          "id": 1,
          "method": 'eth_gasPrice',
          "params": []
        }
      end

      let(:settings) do
        {
          wallet: deposit_wallet_eth.to_wallet_api_settings,
          currency: eth.to_blockchain_api_settings
        }
      end

      before do
        wallet.configure(settings)
      end

      it 'requests rpc and sends transaction' do
        txid = '0xab6ada9608f4cebf799ee8be20fe3fb84b0d08efcdb0d962df45d6fce70cb017'
        stub_request(:post, uri)
          .with(body: eth_GasPrice.to_json)
          .to_return(body: { result: gas_price_hex,
                             error: nil,
                             id: 1 }.to_json)

        stub_request(:post, uri)
          .with(body: request_body.to_json)
          .to_return(body: { result: txid,
                             error: nil,
                             id: 1 }.to_json)

        result = wallet.create_transaction!(transaction, subtract_fee: true)
        expect(result.as_json.symbolize_keys).to eq(amount: 1.099979.to_s,
                                                    currency_id: 'eth',
                                                    to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
                                                    hash: txid,
                                                    status: 'pending',
                                                    options: { 'gas_limit' => 21_000, 'gas_price' => 1_000_000_000, 'subtract_fee' => true })
      end

      context 'without subtract fees' do
        let(:value) { 1_100_000_000_000_000_000 }

        let(:request_body) do
          { jsonrpc: '2.0',
            id: 2,
            method: :personal_sendTransaction,
            params: [{
              from: deposit_wallet_eth.address.downcase,
              to: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
              value: '0x' + (value.to_s 16),
              gas: '0x' + (gas_limit.to_s 16),
              gasPrice: gas_price_hex
            }, 'changeme'] }
        end

        it 'requests rpc and sends transaction' do
          txid = '0xab6ada9608f4cebf799ee8be20fe3fb84b0d08efcdb0d962df45d6fce70cb017'
          stub_request(:post, uri)
            .with(body: eth_GasPrice.to_json)
            .to_return(body: { result: gas_price_hex,
                               error: nil,
                               id: 1 }.to_json)

          stub_request(:post, uri)
            .with(body: request_body.to_json)
            .to_return(body: { result: txid,
                               error: nil,
                               id: 1 }.to_json)

          result = wallet.create_transaction!(transaction)
          expect(result.as_json.symbolize_keys).to eq(amount: 1.1.to_s,
                                                      currency_id: 'eth',
                                                      to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
                                                      hash: txid,
                                                      status: 'pending',
                                                      options: { 'gas_limit' => 21_000, 'gas_price' => 1_000_000_000.0 })
        end
      end

      context 'custom gas_price and subcstract fees' do
        let(:value) { 1_099_976_900_000_000_000 }

        let(:gas_price) { 1_100_000_000 }
        let(:gas_mode) { :standard }

        let(:request_body) do
          { jsonrpc: '2.0',
            id: 2,
            method: :personal_sendTransaction,
            params: [{
              from: deposit_wallet_eth.address.downcase,
              to: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
              value: '0x' + (value.to_s 16),
              gas: '0x' + (gas_limit.to_s 16),
              gasPrice: gas_price_hex
            }, 'changeme'] }
        end

        before do
          settings[:currency][:options] = { gas_price: gas_mode }
          wallet.configure(settings)
        end

        it do
          txid = '0xab6ada9608f4cebf799ee8be20fe3fb84b0d08efcdb0d962df45d6fce70cb017'
          stub_request(:post, uri)
            .with(body: eth_GasPrice.to_json)
            .to_return(body: { result: gas_price_hex,
                               error: nil,
                               id: 1 }.to_json)

          stub_request(:post, uri)
            .with(body: request_body.to_json)
            .to_return(body: { result: txid,
                               error: nil,
                               id: 1 }.to_json)
          result = wallet.create_transaction!(transaction, subtract_fee: true)
          expect(result.as_json.symbolize_keys).to eq(amount: 1.0999769.to_s,
                                                      currency_id: 'eth',
                                                      to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
                                                      hash: txid,
                                                      status: 'pending',
                                                      options: { 'gas_limit' => 21_000, 'gas_price' => 1_100_000_000, 'subtract_fee' => true })
        end
      end
    end

    context 'erc20 transaction' do
      let(:settings) do
        {
          wallet: deposit_wallet_trst.to_wallet_api_settings,
          currency: trst.to_blockchain_api_settings
        }
      end

      let(:gas_price) { 1_000_000_000 }
      let(:gas_price_hex) { '0x' + gas_price.to_s(16) }

      let(:eth_GasPrice) do
        {
          "jsonrpc": '2.0',
          "id": 1,
          "method": 'eth_gasPrice',
          "params": []
        }
      end

      let(:request_body) do
        { jsonrpc: '2.0',
          id: 2,
          method: :personal_sendTransaction,
          params: [{
            from: deposit_wallet_eth.address.downcase,
            to: trst.options.fetch('erc20_contract_address'),
            data: '0xa9059cbb0000000000000000000000006d6cabaa7232d7f45b143b445114f7e92350a2aa000000000000000000000000000000000000000000000000000000000010c8e0',
            gas: '0x15f90',
            gasPrice: gas_price_hex
          }, 'changeme'] }
      end

      before do
        wallet.configure(settings)
      end

      it do
        txid = '0xab6ada9608f4cebf799ee8be20fe3fb84b0d08efcdb0d962df45d6fce70cb017'
        stub_request(:post, uri)
          .with(body: eth_GasPrice.to_json)
          .to_return(body: { result: gas_price_hex,
                             error: nil,
                             id: 1 }.to_json)

        stub_request(:post, uri)
          .with(body: request_body.to_json)
          .to_return(body: { result: txid,
                             error: nil,
                             id: 1 }.to_json)
        result = wallet.create_transaction!(transaction)
        expect(result.as_json.symbolize_keys).to eq(amount: 1.1.to_s,
                                                    to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
                                                    hash: txid,
                                                    status: 'pending',
                                                    options: { 'erc20_contract_address' => '0x87099add3bcc0821b5b151307c147215f839a110', 'gas_limit' => 90_000, 'gas_price' => 1_000_000_000 })
      end
    end

    context :prepare_deposit_collection! do
      let(:value) { '0xa3b5840f4000' }

      let(:gas_price) { 1_000_000_000 }
      let(:gas_price_hex) { '0x' + gas_price.to_s(16) }

      let(:eth_GasPrice) do
        {
          "jsonrpc": '2.0',
          "id": 1,
          "method": 'eth_gasPrice',
          "params": []
        }
      end

      let(:request_body) do
        { jsonrpc: '2.0',
          id: 2,
          method: :personal_sendTransaction,
          params: [{
            from: fee_wallet.address.downcase,
            to: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
            value: value,
            gas: '0x5208',
            gasPrice: '0x3b9aca00'
          }, 'changeme'] }
      end

      let(:spread_deposit) do
        [{ to_address: 'fake-hot',
           amount: '2.0',
           currency_id: trst.currency_id },
         { to_address: 'fake-hot',
           amount: '2.0',
           currency_id: trst.currency_id }]
      end

      let(:settings) do
        {
          wallet: fee_wallet.to_wallet_api_settings,
          currency: eth.to_blockchain_api_settings.merge(min_collection_amount: '1.0')
        }
      end

      before do
        wallet.configure(settings)
      end

      it do
        txid = '0xab6ada9608f4cebf799ee8be20fe3fb84b0d08efcdb0d962df45d6fce70cb017'

        stub_request(:post, uri)
          .with(body: eth_GasPrice.to_json)
          .to_return(body: { result: gas_price_hex,
                             error: nil,
                             id: 1 }.to_json)

        stub_request(:post, uri)
          .with(body: request_body.to_json)
          .to_return(body: { result: txid,
                             error: nil,
                             id: 1 }.to_json)
        result = wallet.prepare_deposit_collection!(transaction, spread_deposit, trst.to_blockchain_api_settings)
        expect(result.first.as_json.symbolize_keys).to eq(amount: '0.00018',
                                                          currency_id: 'eth',
                                                          to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
                                                          hash: txid,
                                                          status: 'pending',
                                                          options: {"gas_limit"=>21000, "gas_price"=>1000000000})
      end

      context 'erc20_contract_address is not configured properly in currency' do
        it 'returns empty array' do
          currency = trst.to_blockchain_api_settings.deep_dup
          currency[:options].delete(:erc20_contract_address)
          expect(wallet.prepare_deposit_collection!(transaction, spread_deposit, currency)).to eq []
        end
      end

      context '#calculate_gas_price' do
        let(:gas_price) { 1_000_000_000 }
        let(:gas_price_hex) { '0x' + gas_price.to_s(16) }

        let(:settings) do
          {
            wallet: fee_wallet.to_wallet_api_settings,
            currency: eth.to_blockchain_api_settings
          }
        end

        let(:eth_GasPrice) do
          {
            "jsonrpc": '2.0',
            "id": 1,
            "method": 'eth_gasPrice',
            "params": []
          }
        end

        before do
          wallet.configure(settings)
          stub_request(:post, uri)
            .with(body: eth_GasPrice.to_json)
            .to_return(body: { result: gas_price_hex,
                              error: nil,
                              id: 1 }.to_json)
        end

        it do
          options = { gas_price: 'standard' }
          expect(wallet.send(:calculate_gas_price, options)).to eq gas_price
        end

        it do
          options = { gas_price: 'fast' }
          expect(wallet.send(:calculate_gas_price, options)).to eq gas_price * 1.1
        end

        it do
          options = { gas_price: 'safelow' }
          expect(wallet.send(:calculate_gas_price, options)).to eq gas_price * 0.9
        end

        it do
          options = { gas_price: 12_346_789.to_s(16) }
          expect(wallet.send(:calculate_gas_price, options)).to eq gas_price
        end

        it do
          expect(wallet.send(:calculate_gas_price)).to eq gas_price
        end

        it do
          expect(wallet.send(:calculate_gas_price, {})).to eq gas_price
        end
      end

      context 'unsuccessful' do
        let(:settings) do
          {
            wallet: fee_wallet.to_wallet_api_settings,
            currency: eth.to_blockchain_api_settings
          }
        end

        before do
          wallet.configure(settings)
        end

        it 'should raise an error' do
          txid = '0xab6ada9608f4cebf799ee8be20fe3fb84b0d08efcdb0d962df45d6fce70cb017'

          stub_request(:post, uri)
            .with(body: eth_GasPrice.to_json)
            .to_return(body: { result: gas_price_hex,
                              error: nil,
                              id: 1 }.to_json)

          stub_request(:post, uri)
            .with(body: request_body.to_json)
            .to_return(body: { result: txid,
                              error: nil,
                              id: 1 }.to_json)
          expect {
            wallet.prepare_deposit_collection!(transaction, spread_deposit, trst.to_blockchain_api_settings)
          }.to raise_error(Peatio::Wallet::ClientError)
        end
      end
    end
  end

  context :load_balance_of_address! do
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

    let(:hot_wallet_trst) { Wallet.joins(:currencies).find_by(currencies: { id: :trst }, kind: :hot) }
    let(:hot_wallet_eth) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :hot) }

    let(:response1) do
      {
        jsonrpc: '2.0',
        result: '0x71a5c4e9fe8a100',
        id: 1
      }
    end

    let(:response2) do
      {
        jsonrpc: '2.0',
        result: '0x7a120',
        id: 1
      }
    end

    let(:settings1) do
      {
        wallet:
          { address: 'something',
            uri: 'http://127.0.0.1:8545' },
        currency: eth.to_blockchain_api_settings
      }
    end

    let(:settings2) do
      {
        wallet:
          { address: 'something',
            uri: 'http://127.0.0.1:8545' },
        currency: trst.to_blockchain_api_settings
      }
    end

    before do
      stub_request(:post, 'http://127.0.0.1:8545')
        .with(body: { jsonrpc: '2.0',
                      id: 1,
                      method: :eth_getBalance,
                      params:
                        %w[
                          something
                          latest
                        ] }.to_json)
        .to_return(body: response1.to_json)

      stub_request(:post, 'http://127.0.0.1:8545')
        .with(body: { jsonrpc: '2.0',
                      id: 1,
                      method: :eth_call,
                      params:
                        [
                          {
                            to: '0x87099add3bcc0821b5b151307c147215f839a110',
                            data: '0x70a082310000000000000000000000000000000000000000000000000000000something'
                          },
                          'latest'
                        ] }.to_json)
        .to_return(body: response2.to_json)
    end

    it 'requests rpc eth_getBalance and get balance' do
      wallet.configure(settings1)
      result = wallet.load_balance!
      expect(result).to be_a(BigDecimal)
      expect(result).to eq('0.51182300042'.to_d)
    end

    it 'requests rpc eth_call and get token balance' do
      wallet.configure(settings2)
      result = wallet.load_balance!
      expect(result).to be_a(BigDecimal)
      expect(result).to eq('0.5'.to_d)
    end
  end
end
