describe OWHDWallet::WalletETH do
  let(:wallet_btc) { OWHDWallet::WalletBTC.new }
  let(:uri) { 'http://127.0.0.1:8000/api/v2/hdwallet' }
  let(:gateway_url) { 'https://btcnode/v3/08825a23f9454f998e6e7ba60bb6f023' }
  let(:btc) do
    BlockchainCurrency.find_by(currency_id: :btc)
  end

  context 'btc transaction' do
    let(:settings) do
      {
        wallet:
          { address:      'something',
            uri:          uri,
            secret:       'changeme',
            wallet_index: 1,
            gateway_url:  gateway_url },
        currency: btc.to_blockchain_api_settings
      }
    end

    before do
      wallet_btc.configure(settings)
    end

    let(:uri_result) do
      {
        'tx': '0xa56316b637a94c4cc0331c73ef26389d6c097506d581073f927275e7a6ece0bc'
      }
    end

    let(:transaction) do
      Peatio::Transaction.new(amount: 1.1.to_d, to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa')
    end

    let(:request_params) do
      {
        coin_type:    'btc',
        to:           transaction.to_address,
        amount:       (transaction.amount.to_d * btc.base_factor).to_i,
        gateway_url:  gateway_url,
        wallet_index: 1,
        passphrase:   'changeme'
      }
    end

    it 'should create transaction' do
      stub_request(:post, uri + '/tx/send')
        .with(body: request_params.to_json)
        .to_return(body: uri_result.to_json)

      result = wallet_btc.create_transaction!(transaction)
      expect(result.as_json.symbolize_keys).to eq(amount: 1.1.to_s,
                                                  to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
                                                  hash: '0xa56316b637a94c4cc0331c73ef26389d6c097506d581073f927275e7a6ece0bc',
                                                  status: 'pending')
    end
  end

  context :load_balance! do
    around do |example|
      WebMock.disable_net_connect!
      example.run
      WebMock.allow_net_connect!
    end

    context 'btc load balance' do
      let(:settings) do
        {
          wallet:
            { address:     'something',
              uri:         uri,
              gateway_url:  gateway_url},
          currency: btc.to_blockchain_api_settings
        }
      end

      let(:uri_result) do
        {
          'balance': 23.2
        }
      end

      let(:request_params) do
        {
          coin_type:   'btc',
          gateway_url: gateway_url,
          address:     'something',
        }
      end

      before do
        wallet_btc.configure(settings)
      end

      it 'should return wallet balance' do
        stub_request(:post, uri + '/wallet/balance')
          .with(body: request_params.to_json)
          .to_return(body: uri_result.to_json)

        wallet_btc.configure(settings)
        result = wallet_btc.load_balance!
        expect(result).to be_a(BigDecimal)
        expect(result).to eq('23.2'.to_d)
      end
    end
  end
end
