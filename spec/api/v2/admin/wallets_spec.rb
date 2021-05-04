# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Wallets, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/wallets/:id' do
    let(:wallet) { Wallet.find_by(blockchain_key: 'eth-rinkeby') }

    it 'returns information about specified wallet' do
      api_get "/api/v2/admin/wallets/#{wallet.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq wallet.id
      expect(result.fetch('currencies')).to eq wallet.currency_ids
      expect(result.fetch('address')).to eq wallet.address
    end

    it 'returns error in case of invalid id' do
      api_get '/api/v2/admin/wallets/0', token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/wallets/#{wallet.id}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    it 'returns information about specified wallet' do
      api_get "/api/v2/admin/wallets/#{wallet.id}", token: token
      expect(response).to be_successful
      result = JSON.parse(response.body)

      expect(result).not_to include('settings')
    end

    it 'returns NA balance if node not accessible' do
      wallet.update(balance: wallet.current_balance)
      api_get "/api/v2/admin/wallets/#{wallet.id}", token: token
      expect(response).to be_successful
      expect(response_body['balance']).to eq(wallet.current_balance)
    end

    it 'returns wallet balance if node accessible' do
      wallet.update(balance: { 'eth' => '1'})

      api_get "/api/v2/admin/wallets/#{wallet.id}", token: token
      expect(response).to be_successful
      expect(response_body['balance']).to eq({ 'eth' => '1' })
    end
  end

  describe 'GET /api/v2/admin/wallets' do
    it 'lists of wallets' do
      api_get '/api/v2/admin/wallets', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq Wallet.count
    end

    it 'returns paginated wallets' do
      api_get '/api/v2/admin/wallets', params: { limit: 6, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq Wallet.count.to_s
      expect(result.size).to eq 6
      expect(result.first['name']).to eq 'Bitcoin Deposit Wallet'

      api_get '/api/v2/admin/wallets', params: { limit: 6, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq Wallet.count.to_s
      expect(result.size).to eq 2
      expect(result.first['name']).to eq 'Ethereum Hot Wallet'
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/wallets", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    context 'filtering' do
      it 'filters by blockchain key' do
        api_get "/api/v2/admin/wallets", token: token, params: { blockchain_key: "eth-rinkeby" }

        result = JSON.parse(response.body)

        expect(result.length).not_to eq 0
        expect(result.map { |r| r["blockchain_key"]}).to all eq "eth-rinkeby"
      end

      it 'filters by kind'do
        api_get "/api/v2/admin/wallets", token: token, params: { kind: "deposit" }

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
          api_get '/api/v2/admin/wallets', token: token, params: { currencies: 'eth' }

          expect(response_body.length).not_to eq 0
          expect(response_body.pluck('currencies').map { |a| a.include?('eth') }.all?).to eq(true)
          count = Wallet.joins(:currencies).where(currencies: { id: :eth }).count
          expect(response_body.find { |c| c['id'] == hot_wallet.id }['currencies'].sort).to eq(%w[eth trst])
          expect(response_body.count).to eq(count)
        end

        it 'filters by currency' do
          api_get '/api/v2/admin/wallets', token: token, params: { currencies: %w[eth trst] }

          expect(response_body.length).not_to eq 0
          count = Wallet.joins(:currencies).where(currencies: { id: %i[eth trst] }).distinct.count
          expect(response_body.find { |c| c['id'] == hot_wallet.id }['currencies'].sort).to eq(%w[eth trst])
          expect(response_body.count).to eq(count)
        end
      end
    end
  end

  describe 'GET /api/v2/admin/wallets/overview' do
    context 'successful response' do
      let(:currency) { Currency.find(:btc) }
      let(:blockchain_key) { 'btc-testnet' }

      before do
        Currency.active.where.not(id: currency.id).map { |c| c.update(status: :disabled) }
        BlockchainCurrency.active.where.not(currency_id: currency.id).map { |c| c.update(status: :disabled) }
      end

      let(:expected_zero_result) {
        [{"id"=>1,
          "name"=>"Bitcoin",
          "code"=>"btc",
          "precision"=>8,
          "blockchains"=>
           [{"blockchain_key"=>"btc-testnet",
             "blockchain_name"=>"Bitcoin Testnet",
             "network"=>"BEP-2",
             "balances"=>[{"kind"=>"hot", "balance"=>0}, {"kind"=>"deposit", "balance"=>0}],
             "total"=>0,
             "estimated_total"=>"0.0"}],
          "total"=>0,
          "deposit_total_balance"=>"0.0",
          "fee_total_balance"=>"0.0",
          "hot_total_balance"=>"0.0",
          "warm_total_balance"=>"0.0",
          "cold_total_balance"=>"0.0",
          "estimated_total"=>"0.0"}]
      }

      before(:each) { clear_redis }

      context 'wallet balances are nil' do
        it 'returns wallet overview' do
          expect(Wallet.where(blockchain_key: 'btc-testnet').map(&:balance).uniq).to eq([nil])
          api_get '/api/v2/admin/wallets/overview', token: token
          
          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result[0].except('blockchains')).to eq expected_zero_result[0].except('blockchains')
          expect(result[0]['blockchains'][0].except('balances')).to eq expected_zero_result[0]['blockchains'][0].except('balances')
        end
      end

      context 'with N/A balances' do
        before do
          Wallet.where(blockchain_key: 'btc-testnet').map do |w|
            w.update(balance: { btc: 'N/A' })
          end
        end

        it 'returns wallet overview' do
          api_get '/api/v2/admin/wallets/overview', token: token

          expect(response).to be_successful
          result = JSON.parse(response.body)
          expect(result[0].except('blockchains')).to eq expected_zero_result[0].except('blockchains')
          expect(result[0]['blockchains'][0].except('balances')).to eq expected_zero_result[0]['blockchains'][0].except('balances')
        end
      end

      context 'with updated_at more than 5m' do
        before do
          Wallet.find_by(blockchain_key: blockchain_key, kind: 'deposit')
                .update(balance: { btc: '32' }, updated_at: 6.minutes.ago)

          Wallet.find_by(blockchain_key: blockchain_key, kind: 'hot')
                .update(balance: { btc: '44' }, updated_at: 6.minutes.ago)
        end

        it 'returns wallet overview' do
          api_get '/api/v2/admin/wallets/overview', token: token

          expect(response).to be_successful
          result = JSON.parse(response.body)

          balances = result[0]['blockchains'][0]['balances']
          expect(balances[0].keys).to eq %w[kind balance updated_at]
          expect(balances[1].keys).to eq %w[kind balance updated_at]

          hot_balance = balances.find { |h| h['kind'] == 'hot' }
          expect(hot_balance['balance']).to eq '44.0'

          deposit_balance = balances.find { |h| h['kind'] == 'deposit' }
          expect(deposit_balance['balance']).to eq '32.0'

          expect(result[0]['blockchains'][0]['total']).to eq '76.0'
          expect(result[0]['blockchains'][0]['estimated_total']).to eq '76.0'
          expect(result[0]['deposit_total_balance']).to eq '32.0'
          expect(result[0]['fee_total_balance']).to eq '0.0'
          expect(result[0]['hot_total_balance']).to eq '44.0'
          expect(result[0]['warm_total_balance']).to eq '0.0'
          expect(result[0]['cold_total_balance']).to eq '0.0'
        end
      end

      context 'with updated_at less that 5m' do
        before do
          Wallet.find_by(blockchain_key: blockchain_key, kind: 'deposit')
                .update(balance: { btc: '32' })

          Wallet.find_by(blockchain_key: blockchain_key, kind: 'hot')
                .update(balance: { btc: '44' })
        end

        it 'returns wallet overview' do
          api_get '/api/v2/admin/wallets/overview', token: token

          expect(response).to be_successful
          result = JSON.parse(response.body)

          balances = result[0]['blockchains'][0]['balances']
          expect(balances[0].keys).to eq %w[kind balance]
          expect(balances[1].keys).to eq %w[kind balance]

          hot_balance = balances.find { |h| h['kind'] == 'hot' }
          expect(hot_balance['balance']).to eq '44.0'
          deposit_balance = balances.find { |h| h['kind'] == 'deposit' }
          expect(deposit_balance['balance']).to eq '32.0'

          expect(result[0]['blockchains'][0]['total']).to eq '76.0'
          expect(result[0]['blockchains'][0]['estimated_total']).to eq '76.0'
        end
      end
    end

    context 'unsuccessful response' do
      it 'return error in case of not permitted ability' do
        api_get '/api/v2/admin/wallets/overview', token: level_3_member_token
        expect(response.code).to eq '403'
        expect(response).to include_api_error('admin.ability.not_permitted')
      end
    end
  end

  describe 'GET /api/v2/admin/wallets/kinds' do
    it 'list kinds' do
      api_get '/api/v2/admin/wallets/kinds', token: token
      expect(response).to be_successful
    end
  end

  describe 'GET /api/v2/admin/wallets/gateways' do
    it 'list gateways' do
      api_get '/api/v2/admin/wallets/gateways', token: token
      expect(response).to be_successful
    end
  end

  describe 'POST /api/v2/admin/wallets/new' do
    it 'create wallet' do
      api_post '/api/v2/admin/wallets/new', params: { name: 'Test', kind: 'deposit', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', plain_settings: {external_wallet_id: 1}, settings: { uri: 'http://127.0.0.1:18332'}}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['name']).to eq 'Test'
    end

    it 'create wallet' do
      api_post '/api/v2/admin/wallets/new', params: { name: 'Test', kind: 'deposit', currencies: ['eth','trst'], address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', plain_settings: {external_wallet_id: 1}, settings: { uri: 'http://127.0.0.1:18332'}}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currencies']).to eq(['eth', 'trst'])
      expect(result['name']).to eq 'Test'
    end

    it 'checked required params' do
      api_post '/api/v2/admin/wallets/new', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.wallet.missing_name')
      expect(response).to include_api_error('admin.wallet.missing_kind')
      expect(response).to include_api_error('admin.wallet.currencies_field_is_missing')
      expect(response).to include_api_error('admin.wallet.missing_blockchain_key')
      expect(response).to include_api_error('admin.wallet.missing_gateway')
    end

    it 'validate status' do
      api_post '/api/v2/admin/wallets/new', params: { name: 'Test', kind: 'deposit', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', plain_settings: {external_wallet_id: 1}, settings: { uri: 'http://127.0.0.1:18332'}, status: 'disable' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.invalid_status')
    end

    it 'validate gateway' do
      api_post '/api/v2/admin/wallets/update', params: { name: 'Test', kind: 'deposit', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', plain_settings: {external_wallet_id: 1}, settings: { uri: 'http://127.0.0.1:18332'}, gateway: 'test' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.gateway_doesnt_exist')
    end

    it 'validate kind' do
      api_post '/api/v2/admin/wallets/update', params: { name: 'Test', kind: 'test', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', plain_settings: {external_wallet_id: 1}, settings: { uri: 'http://127.0.0.1:18332'}, gateway: 'geth' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.invalid_kind')
    end

    it 'validate currency_id' do
      api_post '/api/v2/admin/wallets/update', params: { id: 1, name: 'Test', kind: 'deposit', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', plain_settings: {external_wallet_id: 1}, settings: { uri: 'http://127.0.0.1:18332'}, currencies: 'test' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.currency_doesnt_exist')
    end

    it 'validate uri' do
      api_post '/api/v2/admin/wallets/new', params: { name: 'Test', kind: 'hot', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', plain_settings: {external_wallet_id: 1}, settings: { uri: 'invalid_uri'}, gateway: 'geth' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.invalid_uri_setting')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/wallets/new', params: { name: 'Test', kind: 'deposit', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', gateway: 'geth', plain_settings: {external_wallet_id: 1}, settings: { uri: 'http://127.0.0.1:18332'}}, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    context 'validate wallet kind is supported by the gateway' do
      class CustomWallet < Peatio::Wallet::Abstract
        def initialize(_opts = {}); end
        def configure(settings = {}); end

        def support_wallet_kind?(kind)
          kind == 'hot'
        end
      end

      before(:all) do
        Peatio::Wallet.registry[:custom] = CustomWallet
      end

      it do
        api_post '/api/v2/admin/wallets/new', params: { name: 'Test', kind: 'hot', currencies: ['eth','trst'], address: 'blank', blockchain_key: 'btc-testnet', gateway: 'custom', settings: { uri: 'http://127.0.0.1:18332'}}, token: token

        expect(response).to be_successful
        expect(response_body['gateway']).to eq 'custom'
      end

      it 'returns error' do
        api_post '/api/v2/admin/wallets/new', params: { name: 'Test', kind: 'deposit', currencies: ['eth','trst'], address: 'blank', blockchain_key: 'btc-testnet', gateway: 'custom', settings: { uri: 'http://127.0.0.1:18332'}}, token: token

        expect(response.code).to eq '422'
        expect(response).to include_api_error("Gateway custom can't be used as a deposit wallet")
      end
    end
  end

  describe 'POST /api/v2/admin/wallets/update' do
    it 'update wallet' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, gateway: 'geth' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['gateway']).to eq 'geth'
    end

    it 'update currency' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, currencies: 'btc' }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currencies']).to eq ['btc']
    end

    it 'update wallet with new secret' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, currencies: 'btc', settings: { secret: 'new secret'} }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currencies']).to eq ['btc']
      expect(Wallet.first.settings['uri']).to eq nil
      expect(Wallet.first.settings['secret']).to eq 'new secret'
    end

    it 'update wallet with settings' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, currencies: 'btc', settings: { secret: 'new secret', access_token: 'new token'} }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['currencies']).to eq ['btc']
      expect(Wallet.first.settings['uri']).to eq nil
      expect(Wallet.first.settings['access_token']).to eq 'new token'
      expect(Wallet.first.settings['secret']).to eq 'new secret'
    end

    it 'validate blockchain_key' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, blockchain_key: 'test' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.blockchain_key_doesnt_exist')
    end

    it 'validate status' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, status: 'disable' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.invalid_status')
    end

    it 'validate gateway' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, gateway: 'test' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.gateway_doesnt_exist')
    end

    it 'validate kind' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, kind: 'test' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.invalid_kind')
    end

    it 'validate currency_id' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, currencies: 'test ' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.currency_doesnt_exist')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/wallets/update', params: { }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.wallet.missing_id')
    end

    it 'validate uri' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, name: 'Test', kind: 'hot', currencies: 'eth', address: 'blank', blockchain_key: 'btc-testnet', settings: { uri: 'invalid_uri'}, gateway: 'geth' }, token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.wallet.invalid_uri_setting')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/wallets/update', params: { id: Wallet.first.id, status: 'disabled' }, token: level_3_member_token

      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/wallets/currencies' do
    let(:wallet) { Wallet.joins(:currencies).find_by(currencies: { id: 'eth' }) }

    it do
      api_post '/api/v2/admin/wallets/currencies', params: { id: wallet.id, currencies: 'trst' }, token: token

      expect(response).to be_successful
      expect(response_body['currencies'].include?('trst')).to be_truthy
    end

    it do
      api_post '/api/v2/admin/wallets/currencies', params: { id: wallet.id, currencies: 'eth' }, token: token

      expect(response).to have_http_status 422
      expect(response).to include_api_error('Currency has already been taken')
    end
  end

  describe 'POST /api/v2/admin/wallets/currencies' do
    let(:wallet) { Wallet.joins(:currencies).find_by(currencies: { id: 'eth' }) }

    it do
      api_delete '/api/v2/admin/wallets/currencies', params: { id: wallet.id, currencies: 'eth' }, token: token

      expect(response).to be_successful
      expect(response_body['currencies'].include?('eth')).to be_falsey
    end

    it do
      api_delete '/api/v2/admin/wallets/currencies', params: { id: wallet.id, currencies: 'trst' }, token: token

      expect(response).to have_http_status 404
    end
  end
end
