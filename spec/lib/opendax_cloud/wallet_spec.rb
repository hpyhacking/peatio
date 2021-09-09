describe OpendaxCloud::Wallet do
  let(:wallet) { OpendaxCloud::Wallet.new }

  before(:each) { ENV['PLATFORM_ID'] = 'opendax'}
  after(:each) { ENV.delete('PLATFORM_ID') }
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

    let(:uri) { 'http://127.0.0.1:8000' }

    let(:settings) do
      {
        wallet:
          { address:     'something',
            uri:         uri
          },
        currency: eth.to_blockchain_api_settings
      }
    end

    let(:uri_result) do
      {
        address: '0xa57e810B5f96b049F9030AfE1f1004630818EC72',
        currency_id: 'eth',
      }
    end

    before do
      wallet.configure(settings)
    end

    it 'should create an address' do
      stub_request(:post, uri + '/address/new')
        .with(body: {currency_id: 'eth'}.to_json)
        .to_return(body: uri_result.to_json)

      result = wallet.create_address!(uid: 'UID123')

      expect(result.as_json.symbolize_keys).to eq(address: uri_result[:address],
                                                  details: uri_result.except(:address, :passphrase).with_indifferent_access)
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

    let(:deposit_wallet_eth) { Wallet.joins(:currencies).find_by(currencies: { id: :eth }, kind: :deposit) }

    let(:uri) { 'http://127.0.0.1:8000' }

    let(:transaction) do
      Peatio::Transaction.new(amount: 1.1.to_d, to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa')
    end

    context 'eth transaction' do
      let(:settings) do
        {
          wallet: {
            settings:     deposit_wallet_eth.settings,
            uri:          uri,
            address:      deposit_wallet_eth.address,
          },
          currency: eth.to_blockchain_api_settings
        }
      end

      before do
        wallet.configure(settings)
      end

      let(:uri_result) do
        {
          'tid': 'TIDDAD0E517F2',
          'fee': '0.1',
        }
      end

      let(:request_params) do
        {
          currency_id: 'eth',
          to_address:  transaction.to_address,
          amount:      transaction.amount.to_d,
        }
      end

      it 'should create transaction' do
        stub_request(:post, uri + '/tx/send')
          .with(body: request_params.to_json)
          .to_return(body: uri_result.to_json)

        result = wallet.create_transaction!(transaction)
        expect(result.as_json.symbolize_keys).to eq(amount: 1.1.to_s,
                                                    to_address: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa',
                                                    options: {"tid"=>"TIDDAD0E517F2"},
                                                    fee: '0.1',
                                                    fee_currency_id: 'eth',
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

    let(:uri) { 'http://127.0.0.1:8000' }

    context 'eth load_balance' do
      let(:settings) do
        {
          wallet:
            { address:     'something',
              uri:         uri },
          currency: eth.to_blockchain_api_settings
        }
      end

      before do
        wallet.configure(settings)
      end

      let(:uri_result) do
        {
          'balance': 5.1
        }
      end

      let(:request_params) do
        {
          currency_id: 'eth',
        }
      end

      it 'should return wallet balance' do
        stub_request(:post, uri + '/address/balance')
          .with(body: request_params.to_json)
          .to_return(body: uri_result.to_json)

        wallet.configure(settings)
        result = wallet.load_balance!
        expect(result).to be_a(BigDecimal)
        expect(result).to eq('5.1'.to_d)
      end
    end
  end

  context :trigger_webhook_event do
    let(:rsa_private) { OpenSSL::PKey::EC.generate('prime256v1') }

    let(:payload) {
      {
        currency: 'eth',
        amount: '1000000000000000000',
        blockchain_txid: 'c37ae1677c4c989dbde9ac22be1f3ff3ac67ed24732a9fa8c9258fdff0232d72',
        state: 'succeed',
        tid: '0x6d6cabaa7232d7f45b143b445114f7e92350a2aa'
      }
    }

    let(:eth) do
      BlockchainCurrency.find_by(currency_id: :eth)
    end

    let(:uri) { 'http://127.0.0.1:8000' }

    let(:settings) do
      {
        wallet:
          { address:     'something',
            uri:         uri
          },
        currency: eth.to_blockchain_api_settings
      }
    end

    before do
      wallet.configure(settings)
    end

    let(:jwt_token) { JWT.encode(payload, rsa_private, 'ES256') }

    context 'successful response' do
      before do
        ENV['OPENFINEX_CLOUD_PUBLIC_KEY'] = Base64.urlsafe_encode64(OpenSSL::PKey::EC.new(rsa_private).to_pem)
      end

      context 'deposit' do
        it 'returns transactions' do
          res = wallet.trigger_webhook_event(OpenStruct.new({'body': StringIO.new(jwt_token), 'params': {'event': 'deposit'}}))

          expect(res[0].amount).to eq payload[:amount].to_d
          expect(res[0].currency_id).to eq payload[:currency]
          expect(res[0].hash).to eq payload[:blockchain_txid]
          expect(res[0].status).to eq 'pending'
          expect(res[0].options[:tid]).to eq payload[:tid]
        end
      end

      context 'withdraw' do
        it 'returns transactions' do
          res = wallet.trigger_webhook_event(OpenStruct.new({'body': StringIO.new(jwt_token), 'params': {'event': 'withdraw'}}))

          expect(res[0].amount).to eq payload[:amount].to_d
          expect(res[0].currency_id).to eq payload[:currency]
          expect(res[0].hash).to eq payload[:blockchain_txid]
          expect(res[0].status).to eq 'success'
          expect(res[0].options[:tid]).to eq payload[:tid]
        end
      end
    end

    context 'successful response' do
      before do
        ENV['OPENFINEX_CLOUD_PUBLIC_KEY'] = Base64.urlsafe_encode64(OpenSSL::PKey::EC.generate('prime256v1').to_pem)
      end

      it 'returns error' do
        expect { wallet.trigger_webhook_event(OpenStruct.new({'body': StringIO.new(jwt_token), 'params': {'event': 'deposit'} })) }.to raise_error(JWT::VerificationError)
      end
    end
  end
end
