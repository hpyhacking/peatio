describe Bitcoin::Wallet do
  let(:wallet) { Bitcoin::Wallet.new }

  context :configure do
    let(:settings) { { wallet: {}, currency: {} }}
    it 'requires wallet' do
      expect{ wallet.configure(settings.except(:wallet)) }.to raise_error(Peatio::Wallet::MissingSettingError)

      expect{ wallet.configure(settings) }.to_not raise_error
    end

    it 'requires currency' do
      expect{ wallet.configure(settings.except(:currency)) }.to raise_error(Peatio::Wallet::MissingSettingError)

      expect{ wallet.configure(settings) }.to_not raise_error
    end

    it 'sets settings attribute' do
      wallet.configure(settings)
      expect(wallet.settings).to eq(settings.slice(*Bitcoin::Wallet::SUPPORTED_SETTINGS))
    end
  end

  context :create_address! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:uri) { 'http://user:password@127.0.0.1:18332' }
    let(:uri_without_authority) { 'http://127.0.0.1:18332' }

    let(:uri_with_wallet) { 'http://user:password@127.0.0.1:18332/wallet/testwallet' }
    let(:uri_with_wallet_no_authority) { 'http://127.0.0.1:18332/wallet/testwallet' }

    let(:settings) do
      {
        wallet:
          { address: 'something',
            uri:     uri },
        currency: {}
      }
    end

    before do
      wallet.configure(settings)
    end

    it 'request rpc and creates new address' do
      address = '2N4qYjye5yENLEkz4UkLFxzPaxJatF3kRwf'
      stub_request(:post, uri_without_authority)
        .with(body: { jsonrpc: '1.0',
                      method: :getnewaddress,
                      params:  [] }.to_json)
        .to_return(body: { result: address,
                           error:  nil,
                           id:     nil }.to_json)

      result = wallet.create_address!(uid: 'UID123')
      expect(result.as_json.symbolize_keys).to eq(address: address)
    end

    it 'works with wallet path' do
      wallet.configure({
        wallet: {
          address: 'something',
          uri:     uri_with_wallet },
        currency: {}
      })
      address = '2N4qYjye5yENLEkz4UkLFxzPaxJatF3kRwf'
      stub_request(:post, uri_with_wallet_no_authority)
        .with(body: { jsonrpc: '1.0',
                      method: :getnewaddress,
                      params:  [] }.to_json)
        .to_return(body: { result: address,
                           error:  nil,
                           id:     nil }.to_json)
      result = wallet.create_address!(uid: 'UID123')
      expect(result.as_json.symbolize_keys).to eq(address: address)
    end
  end

  context :create_transaction! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:uri) { 'http://user:password@127.0.0.1:18332' }
    let(:uri_without_authority) { 'http://127.0.0.1:18332' }

    let(:settings) do
      {
        wallet:
          { address: 'something',
            uri:     uri },
        currency: {}
      }
    end

    let(:transaction) do
      Peatio::Transaction.new(amount: 1.1, to_address: '2N4qYjye5yENLEkz4UkLFxzPaxJatF3kRwf')
    end

    before do
      wallet.configure(settings)
    end

    it 'requests rpc and sends transaction without subtract fees' do
      txid = 'ab6ada9608f4cebf799ee8be20fe3fb84b0d08efcdb0d962df45d6fce70cb017'
      stub_request(:post, uri_without_authority)
        .with(body: { jsonrpc: '1.0',
                      method: :sendtoaddress,
                      params: [
                        transaction.to_address,
                        transaction.amount,
                        '',
                        '',
                        false
                      ] }.to_json)
        .to_return(body: { result: txid,
                           error:  nil,
                           id:     nil }.to_json)

      result = wallet.create_transaction!(transaction)
      expect(result.as_json.symbolize_keys).to eq(amount: 1.1,
                                                  to_address: '2N4qYjye5yENLEkz4UkLFxzPaxJatF3kRwf',
                                                  hash: txid,
                                                  status: 'pending')
    end

    it 'requests rpc and sends transaction with subtract fees' do
      txid = 'ab6ada9608f4cebf799ee8be20fe3fb84b0d08efcdb0d962df45d6fce70cb017'
      stub_request(:post, uri_without_authority)
        .with(body: { jsonrpc: '1.0',
                      method: :sendtoaddress,
                      params: [
                        transaction.to_address,
                        transaction.amount,
                        '',
                        '',
                        true
                      ] }.to_json)
        .to_return(body: { result: txid,
                           error:  nil,
                           id:     nil }.to_json)

      result = wallet.create_transaction!(transaction, subtract_fee: true)
      expect(result.as_json.symbolize_keys).to eq(amount: 1.1,
                                                  to_address: '2N4qYjye5yENLEkz4UkLFxzPaxJatF3kRwf',
                                                  hash: txid,
                                                  status: 'pending')
    end
  end

  context :load_balance! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    let(:uri) { 'http://user:password@127.0.0.1:18332' }
    let(:uri_without_authority) { 'http://127.0.0.1:18332' }

    let(:settings) do
      {
        wallet:
          { address: 'something',
            uri:     uri },
        currency: {}
      }
    end

    before do
      wallet.configure(settings)
    end

    it 'requests rpc with getbalance call' do
      balance = '6.72201169'
      stub_request(:post, uri_without_authority)
        .with(body: { jsonrpc: '1.0',
                      method: :getbalance,
                      params: [] }.to_json)
        .to_return(body: { result: balance,
                           error:  nil,
                           id:     nil }.to_json)

      result = wallet.load_balance!
      expect(result).to be_a(BigDecimal)
      expect(result).to eq(balance.to_d)
    end
  end
end
