# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Management::Wallets, type: :request do
  before do
    defaults_for_management_api_v1_security_configuration!
    management_api_v1_security_configuration.merge! \
      scopes: {
        read_wallets:  { permitted_signers: %i[alex jeff],       mandatory_signers: %i[alex] },
        write_wallets: { permitted_signers: %i[alex jeff james], mandatory_signers: %i[alex jeff] }
      }
  end

  describe 'POST /api/v2/management/wallets/:id' do
    def request
      post_json "/api/v2/management/wallets/#{wallet.id}", multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:data) { {} }
    let(:wallet) { Wallet.find_by(blockchain_key: 'eth-rinkeby') }

    it 'returns information about specified wallet' do
      request
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq wallet.id
      expect(result.fetch('currencies')).to eq wallet.currency_ids
      expect(result.fetch('address')).to eq wallet.address
    end

    context do
      let(:wallet) { OpenStruct.new(id: 120)}
      it 'returns error in case of invalid id' do
        request

        expect(response.code).to eq '404'
        expect(response.body).to match(/Couldn't find record./i)
      end
    end


    it 'returns information about specified wallet' do
      request
      expect(response).to be_successful
      result = JSON.parse(response.body)

      expect(result).not_to include('settings')
    end

    it 'returns NA balance if node not accessible' do
      wallet.update(balance: wallet.current_balance)
      request
      expect(response).to be_successful
      expect(response_body['balance']).to eq(wallet.current_balance)
    end

    it 'returns wallet balance if node accessible' do
      wallet.update(balance: { 'eth' => '1'})

      request
      expect(response).to be_successful
      expect(response_body['balance']).to eq({ 'eth' => '1' })
    end
  end

  describe 'POST /api/v2/management/wallets' do
    def request
      post_json "/api/v2/management/wallets", multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:data) { {} }

    it 'lists of wallets' do
      request
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Wallet.count
    end

    it 'returns paginated wallets' do
      data.merge!(limit: 6, page: 1 )
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq Wallet.count.to_s
      expect(result.size).to eq 6
      expect(result.first['name']).to eq 'Ethereum Deposit Wallet'

      data.merge!(limit: 6, page: 2)
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq Wallet.count.to_s
      expect(result.size).to eq 2
      expect(result.first['name']).to eq 'Bitcoin Hot Wallet'
    end

    context 'filtering' do
      it 'filters by blockchain key' do
        data.merge!(blockchain_key: "eth-rinkeby")
        request

        result = JSON.parse(response.body)

        expect(result.length).not_to eq 0
        expect(result.map { |r| r["blockchain_key"]}).to all eq "eth-rinkeby"
      end

      it 'filters by kind'do
        data.merge!(kind: "deposit")
        request

        result = JSON.parse(response.body)

        expect(result.length).not_to eq 0
        expect(result.map { |r| r["kind"]}).to all eq "deposit"
      end

      context do
        let(:hot_wallet) { Wallet.joins(:currencies).find_by(blockchain_key: 'eth-rinkeby', kind: :hot, currencies: { id: :eth }) }

        before do
          hot_wallet.currencies << Currency.find(:trst)
        end

        it 'filters by currency' do
          data.merge!(currencies: 'eth')
          request

          expect(response_body.length).not_to eq 0
          expect(response_body.pluck('currencies').map { |a| a.include?('eth') }.all?).to eq(true)
          count = Wallet.joins(:currencies).where(currencies: { id: :eth }).count
          expect(response_body.find { |c| c['id'] == hot_wallet.id }['currencies'].sort).to eq(%w[eth trst])
          expect(response_body.count).to eq(count)
        end

        it 'filters by currency' do
          data.merge!(currencies: %w[eth trst])
          request

          expect(response_body.length).not_to eq 0
          count = Wallet.joins(:currencies).where(currencies: { id: %i[eth trst] }).distinct.count
          expect(response_body.find { |c| c['id'] == hot_wallet.id }['currencies'].sort).to eq(%w[eth trst])
          expect(response_body.count).to eq(count)
        end
      end
    end
  end

  describe 'POST /api/v2/management/wallets/new' do
    def request
      post_json "/api/v2/management/wallets/new", multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:data) { {} }

    it 'create wallet' do
      data.merge!(name: 'Test', kind: 'deposit', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', settings: { uri: 'http://127.0.0.1:18332'})
      request

      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['name']).to eq 'Test'
    end

    it 'create wallet' do
      data.merge!(name: 'Test', kind: 'deposit', currencies: ['eth','trst'], address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', settings: { uri: 'http://127.0.0.1:18332'})
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currencies']).to eq(['eth', 'trst'])
      expect(result['name']).to eq 'Test'
    end

    it 'checked required params' do
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/blockchain_key is missing, blockchain_key management.wallet.blockchain_key_doesnt_exist, name is missing, kind is missing, kind management.wallet.invalid_kind, gateway is missing, gateway management.wallet.gateway_doesnt_exist, currencies, currency management.wallet.currencies_field_is_missing/i)
    end

    it 'validate status' do
      data.merge!(name: 'Test', kind: 'deposit', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', settings: { uri: 'http://127.0.0.1:18332'}, status: 'disable')
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.invalid_status/i)
    end

    it 'validate gateway' do
      data.merge!(name: 'Test', kind: 'deposit', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', settings: { uri: 'http://127.0.0.1:18332'}, gateway: 'test')
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.gateway_doesnt_exist/i)
    end

    it 'validate kind' do
      data.merge!(name: 'Test', kind: 'test', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', settings: { uri: 'http://127.0.0.1:18332'}, gateway: 'geth')
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.invalid_kind/i)
    end

    it 'validate currency_id' do
      data.merge!(id: 1, name: 'Test', kind: 'deposit', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', settings: { uri: 'http://127.0.0.1:18332'}, currencies: 'test')
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.currency_doesnt_exist/i)
    end

    it 'validate uri' do
      data.merge!(name: 'Test', kind: 'hot', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', settings: { uri: 'invalid_uri'}, gateway: 'geth')
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.invalid_uri_setting/i)
    end

  end

  describe 'POST /api/v2/management/wallets/update' do
    def request
      post_json "/api/v2/management/wallets/update", multisig_jwt_management_api_v1({ data: data }, *signers)
    end

    let(:signers) { %i[alex jeff] }
    let(:data) { {} }

    it 'update wallet' do
      data.merge!(id: Wallet.first.id, gateway: 'geth')
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['gateway']).to eq 'geth'
    end

    it 'update currency' do
      data.merge!(id: Wallet.first.id, currencies: 'btc')
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currencies']).to eq ['btc']
    end

    it 'update wallet with new secret' do
      data.merge!(id: Wallet.first.id, currencies: 'btc', settings: { secret: 'new secret'})

      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currencies']).to eq ['btc']
      expect(Wallet.first.settings['uri']).to eq nil
      expect(Wallet.first.settings['secret']).to eq 'new secret'
    end

    it 'update wallet with settings' do
      data.merge!(id: Wallet.first.id, currencies: 'btc', settings: { secret: 'new secret', access_token: 'new token'})
      request
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currencies']).to eq ['btc']
      expect(Wallet.first.settings['uri']).to eq nil
      expect(Wallet.first.settings['access_token']).to eq 'new token'
      expect(Wallet.first.settings['secret']).to eq 'new secret'
    end

    it 'validate blockchain_key' do
      data.merge!(id: Wallet.first.id, blockchain_key: 'test')
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.blockchain_key_doesnt_exist/i)
    end

    it 'validate status' do
      data.merge!(id: Wallet.first.id, status: 'disable')
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.invalid_status/i)
    end

    it 'validate gateway' do
      data.merge!(id: Wallet.first.id, gateway: 'test')
      request
      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.gateway_doesnt_exist/i)
    end

    it 'validate kind' do
      data.merge!(id: Wallet.first.id, kind: 'test')
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.invalid_kind/i)
    end

    it 'validate currency_id' do
      data.merge!(id: Wallet.first.id, currencies: 'test ')
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.currency_doesnt_exist/i)
    end

    it 'checked required params' do
      request

      expect(response).to have_http_status 422
      expect(response.body).to match(/id is missing/i)
    end

    it 'validate uri' do
      data.merge!(id: Wallet.first.id, name: 'Test', kind: 'hot', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', settings: { uri: 'invalid_uri'}, gateway: 'geth')
      request

      expect(response.code).to eq '422'
      expect(response.body).to match(/management.wallet.invalid_uri_setting/i)
    end
  end
end
