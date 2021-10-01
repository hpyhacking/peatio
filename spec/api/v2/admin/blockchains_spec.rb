# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Admin::Blockchains, type: :request do
  let(:admin) { create(:member, :admin, :level_3, email: 'example@gmail.com', uid: 'ID73BF61C8H0') }
  let(:token) { jwt_for(admin) }
  let(:level_3_member) { create(:member, :level_3) }
  let(:level_3_member_token) { jwt_for(level_3_member) }

  describe 'GET /api/v2/admin/blockchains/:id' do
    let(:blockchain) { Blockchain.find_by(key: 'eth-rinkeby') }

    it 'returns information about specified blockchain' do
      api_get "/api/v2/admin/blockchains/#{blockchain.id}", token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.fetch('id')).to eq blockchain.id
      expect(result.fetch('name')).to eq blockchain.name
    end

    it 'returns error in case of invalid id' do
      api_get "/api/v2/admin/blockchains/#{Blockchain.last.id + 42}", token: token

      expect(response.code).to eq '404'
      expect(response).to include_api_error('record.not_found')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/blockchains/#{blockchain.id}", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'GET /api/v2/admin/blockchains/clients' do
    it 'get list of all available clients' do
      api_get '/api/v2/admin/blockchains/clients', token: token
      expect(JSON.parse(response.body)).to match_array Blockchain.clients.map &:to_s
    end
  end

  describe 'GET /api/v2/admin/blockchains/:id/latest_block' do
    let(:blockchain) { Blockchain.find_by(key: "eth-rinkeby") }

    it 'returns error in case of invalid id' do
      api_get "/api/v2/admin/blockchains/#{Blockchain.last.id + 42}/latest_block", token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.blockchain.latest_block')
    end

    it 'returns error in case of node inaccessibility' do
      api_get "/api/v2/admin/blockchains/#{blockchain.id}/latest_block", token: token

      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.blockchain.latest_block')
    end

    context 'get latest_block' do
      let(:blockchain) { Blockchain.find_by(key: "eth-rinkeby") }

      around do |example|
        WebMock.disable_net_connect!
        example.run
        WebMock.allow_net_connect!
      end

      let(:eth_blockchain) do
        Ethereum::Blockchain.new.tap { |b| b.configure(server: 'http://127.0.0.1:8545') }
      end

      it 'returns node latest block' do
        block_number = '0x16b916'

        stub_request(:post, 'http://127.0.0.1:8545')
          .with(body: { jsonrpc: '2.0',
                        id: 1,
                        method: :eth_blockNumber,
                        params:  [] }.to_json)
          .to_return(body: { result: block_number,
                             error:  nil,
                             id:     1 }.to_json)

        api_get "/api/v2/admin/blockchains/#{blockchain.id}/latest_block", token: token

        expect(response.code).to eq '200'
        expect(response_body).to eq 1489174
      end
    end
  end

  describe 'GET /api/v2/admin/blockchains' do
    it 'lists of blockchains' do
      api_get '/api/v2/admin/blockchains', token: token
      expect(response).to be_successful

      result = JSON.parse(response.body)
      expect(result.size).to eq 4
    end

    it 'returns blockchains by ascending order' do
      api_get '/api/v2/admin/blockchains', params: { ordering: 'asc', order_by: 'client'}, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result.first['client']).to eq 'bitcoin'
    end

    it 'returns paginated blockchains' do
      api_get '/api/v2/admin/blockchains', params: { limit: 2, page: 1 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '4'
      expect(result.size).to eq 2
      expect(result.first['key']).to eq 'btc-testnet'

      api_get '/api/v2/admin/blockchains', params: { limit: 1, page: 2 }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful

      expect(response.headers.fetch('Total')).to eq '4'
      expect(result.size).to eq 1
      expect(result.first['key']).to eq 'eth-rinkeby'
    end

    it 'returns blockchains filtered by key' do
      api_get '/api/v2/admin/blockchains', params: { key: "eth-kovan" }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '1'
      expect(result.size).to eq 1
      expect(result.first['key']).to eq 'eth-kovan'
    end

    it 'returns error in case invalid blockchain key' do
      api_get '/api/v2/admin/blockchains', params: { key: "inv" }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.blockchain.blockchain_key_doesnt_exist')
    end

    it 'returns blockchains filtered by client' do
      api_get '/api/v2/admin/blockchains', params: { client: "parity" }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '1'
      expect(result.size).to eq 1
      expect(result.first['name']).to eq 'Ethereum Kovan'
    end

    it 'returns error in case invalid blockchain client' do
      api_get '/api/v2/admin/blockchains', params: { client: "inv" }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.blockchain.blockchain_client_doesnt_exist')
    end

    it 'returns blockchains filtered by status' do
      api_get '/api/v2/admin/blockchains', params: { status: "active" }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '3'
      expect(result.size).to eq 3
      expect(result.map { |r| r["status"]}).to all eq "active"
    end

    it 'returns error in case invalid blockchain status' do
      api_get '/api/v2/admin/blockchains', params: { status: "inv" }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.blockchain.blockchain_status_doesnt_exist')
    end

    it 'returns blockchains filtered by name' do
      api_get '/api/v2/admin/blockchains', params: { name: "Ethereum Kovan" }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(response.headers.fetch('Total')).to eq '1'
      expect(result.size).to eq 1
      expect(result.first['name']).to eq 'Ethereum Kovan'
    end

    it 'returns error in case invalid blockchain name' do
      api_get '/api/v2/admin/blockchains', params: { name: "inv" }, token: token
      expect(response.code).to eq '422'
      expect(response).to include_api_error('admin.blockchain.blockchain_name_doesnt_exist')
    end

    it 'return error in case of not permitted ability' do
      api_get "/api/v2/admin/blockchains", token: level_3_member_token
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/blockchains/new' do
    it 'creates new blockchain' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth', server: 'http://127.0.0.1',
                                                                        explorer_transaction: 'test', explorer_address: 'test', height: 123333,
                                                                        warning: 'Warning', description: 'Description', protocol: 'Protocol',
                                                                        min_deposit_amount: 1, min_withdraw_amount: 2, withdraw_fee: 0.1,
                                                                        collection_gas_speed: 'standard', withdrawal_gas_speed: 'fast'}
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['key']).to eq 'test-blockchain'
      expect(result['warning']).to eq 'Warning'
      expect(result['description']).to eq 'Description'
      expect(result['protocol']).to eq 'Protocol'
      expect(result['min_deposit_amount']).to eq '1.0'
      expect(result['min_withdraw_amount']).to eq '2.0'
      expect(result['withdraw_fee']).to eq '0.1'
      expect(result['collection_gas_speed']).to eq 'standard'
      expect(result['withdrawal_gas_speed']).to eq 'fast'
    end

    it 'long blockchain key' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: Faker::String.random(1024), name: 'Test', client: 'geth',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test'}
      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.blockchain.key_too_long')
    end

    it 'long blockchain name' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: Faker::String.random(24), name: Faker::String.random(1024), client: 'geth', server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test'}
      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.blockchain.name_too_long')
    end

    it 'validate height param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth', server: 'http://127.0.0.1', height: -123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: 6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.non_positive_height')
    end

    it 'validate min_confirmations param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth', server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: -6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.non_positive_min_confirmations')
    end

    it 'validate status param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth', server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'actived', min_confirmations: 6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.invalid_status')
    end

    it 'validate collection_gas_speed param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth', server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', collection_gas_speed: 'test', min_confirmations: 6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.invalid_collection_gas_speed')
    end

    it 'validate withdrawal_gas_speed param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth', server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', withdrawal_gas_speed: 'test', min_confirmations: 6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.invalid_withdrawal_gas_speed')
    end

    it 'validate client param' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'gezz', server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: 6, step: 2 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.invalid_client')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { }

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.missing_key')
      expect(response).to include_api_error('admin.blockchain.missing_name')
      expect(response).to include_api_error('admin.blockchain.missing_client')
      expect(response).to include_api_error('admin.blockchain.missing_height')
    end

    it 'validates server' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: 'test-blockchain', name: 'Test', client: 'geth',server: 'not_a_url', height: 123333, explorer_transaction: 'test', explorer_address: 'test'}

      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.invalid_server')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/blockchains/new', token: level_3_member_token, params: { protocol: 'Test', key: 'test-blockchain', name: 'Test', client: 'geth', server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test', status: 'active', min_confirmations: 6, step: 2 }
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end

    it 'key already exists' do
      api_post '/api/v2/admin/blockchains/new', token: token, params: { key: Blockchain.first.key, name: 'Test', client: 'geth',server: 'http://127.0.0.1', height: 123333, explorer_transaction: 'test', explorer_address: 'test'}
      expect(response.status).to eq 422
    end
  end

  describe 'POST /api/v2/admin/blockchains/update' do
    context 'permissions' do
      let(:support) { create(:member, :admin, :level_3, role: :support, email: 'example@gmail.com', uid: 'ID73BF61C8H1') }
      let(:support_token) { jwt_for(support) }

      it 'return error in case of not permitted ability' do
        api_post '/api/v2/admin/blockchains/update', params: { key: 'test-blockchain', id: Blockchain.first.id }, token: support_token

        expect(response.code).to eq '403'
        expect(response).to include_api_error('admin.ability.not_permitted')
      end

      it 'returns updated blockchain' do
        api_post '/api/v2/admin/blockchains/update', params: { name: 'Test Blockchain', id: Blockchain.first.id, warning: 'Warning', description: 'Description', protocol: 'Protocol',
                                                               min_deposit_amount: 1, min_withdraw_amount: 2, withdraw_fee: 0.1,
                                                               collection_gas_speed: 'standard', withdrawal_gas_speed: 'fast' }, token: token
        result = JSON.parse(response.body)

        expect(response).to be_successful
        expect(result['name']).to eq 'Test Blockchain'
        expect(result['warning']).to eq 'Warning'
        expect(result['description']).to eq 'Description'
        expect(result['protocol']).to eq 'Protocol'
        expect(result['min_deposit_amount']).to eq '1.0'
        expect(result['min_withdraw_amount']).to eq '2.0'
        expect(result['withdraw_fee']).to eq '0.1'
        expect(result['collection_gas_speed']).to eq 'standard'
        expect(result['withdrawal_gas_speed']).to eq 'fast'
      end
    end

    it 'returns updated blockchain' do
      api_post '/api/v2/admin/blockchains/update', params: { key: 'test-blockchain', id: Blockchain.first.id }, token: token
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['key']).to eq 'test-blockchain'
    end

    it 'returns updated blockchain' do
      api_post '/api/v2/admin/blockchains/update', token: token, params: { key: 'Test-blockchain ', id: Blockchain.first.id }
      result = JSON.parse(response.body)

      expect(response).to be_successful
      expect(result['key']).to eq 'test-blockchain'
    end

    it 'long blockchain key' do
      api_post '/api/v2/admin/blockchains/update', token: token, params: { key: Faker::String.random(1024) }
      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.blockchain.key_too_long')
    end

    it 'validate collection_gas_speed param' do
      api_post '/api/v2/admin/blockchains/update', token: token, params: { id: Blockchain.first.id, collection_gas_speed: 'test' }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.invalid_collection_gas_speed')
    end

    it 'validate withdrawal_gas_speed param' do
      api_post '/api/v2/admin/blockchains/update', token: token, params: {  id: Blockchain.first.id, withdrawal_gas_speed: 'test'}
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.invalid_withdrawal_gas_speed')
    end

    it 'long blockchain name' do
      api_post '/api/v2/admin/blockchains/update', token: token, params: { name: Faker::String.random(1024) }
      expect(response).not_to be_successful
      expect(response).to include_api_error('admin.blockchain.name_too_long')
    end

    it 'validate height param' do
      api_post '/api/v2/admin/blockchains/update', token: token, params: { height: -123333 }
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.non_positive_height')
    end

    it 'checked required params' do
      api_post '/api/v2/admin/blockchains/update', token: level_3_member_token, params: { key: 'test-blockchain'}
      expect(response).to have_http_status 422
      expect(response).to include_api_error('admin.blockchain.missing_id')
    end

    it 'return error in case of not permitted ability' do
      api_post '/api/v2/admin/blockchains/update', token: level_3_member_token, params: { id: Blockchain.first.id }
      expect(response.code).to eq '403'
      expect(response).to include_api_error('admin.ability.not_permitted')
    end
  end

  describe 'POST /api/v2/admin/blockchains/process_block' do
    context 'returns error' do
      it 'in case of not permitted ability' do
        api_post '/api/v2/admin/blockchains/process_block', token: level_3_member_token, params: { block_number: 1, id: Blockchain.last.id }
        expect(response.code).to eq '403'
        expect(response).to include_api_error('admin.ability.not_permitted')
      end

      it 'when blockchain doesnt exist' do
        api_post "/api/v2/admin/blockchains/process_block", params: { block_number: 1, id: Blockchain.last.id + 1 }, token: token
        expect(response.code).to eq '404'
        expect(response).to include_api_error('record.not_found')
      end

      it 'when blockchain is not accessible' do
        api_post "/api/v2/admin/blockchains/process_block", params: { block_number: 1, id: Blockchain.last.id }, token: token

        expect(response).to include_api_error('admin.blockchain.process_block')
      end
    end

    context 'successful' do
      let!(:blockchain) { Blockchain.find_by(key: 'btc-testnet') }
      let(:service) { BlockchainService.new(blockchain) }
      let!(:currency) { create(:currency, :btc, id: 'fake') }
      let!(:blockchain_currency) { BlockchainCurrency.create(currency_id: 'fake', blockchain_key: blockchain.key)}
      let(:block_number) { 3 }
      let!(:member) { create(:member) }
      let!(:fake_blockchain) { create(:blockchain, 'fake-testnet') }
      let!(:wallet) { create(:wallet, :fake_deposit, blockchain_key: blockchain.key) }

      before do
        Blockchain.any_instance.stubs(:blockchain_api).returns(service)
        service.stubs(:latest_block_number).returns(4)
        clear_redis
        PaymentAddress.create!(member: member,
                               wallet: wallet,
                               address: 'fake_address')
      end

      context 'deposit' do
        let(:transaction) { Peatio::Transaction.new(hash: 'fake_txid', from_addresses: ['fake_address'], to_address: 'fake_address', amount: 5, block_number: block_number, currency_id: 'fake', txout: 4, status: 'success') }
        let(:expected_block) { Peatio::Block.new(block_number, [transaction]) }

        before do
          service.adapter.stubs(:fetch_block!).returns(expected_block)
        end

        it 'detects in the block' do
          expect(Deposits::Coin.where(currency: currency, blockchain_key: blockchain.key).exists?).to be false

          api_post '/api/v2/admin/blockchains/process_block', token: token, params: { block_number: block_number, id: blockchain.id }
          expect(response).to be_successful
          expect(Deposits::Coin.where(currency: currency, blockchain_key: blockchain.key).exists?).to be true
        end

        it 'doesn\'t update height of blockchain' do
          blockchain_height = blockchain.height
          expect(blockchain_height).not_to eq (block_number)

          api_post '/api/v2/admin/blockchains/process_block', token: token, params: { block_number: block_number, id: blockchain.id }
          result = JSON.parse(response.body)
          expect(response).to be_successful
          expect(result['height']).not_to eq block_number
          expect(result['height']).to eq blockchain_height
        end
      end

      context 'withdraw' do
        let!(:member_account) { member.get_account(:fake).tap { |ac| ac.update!(balance: 50, locked: 10) } }
        let!(:withdrawal) do
          Withdraw.create!(member: member,
                           currency: currency,
                           amount: 1,
                           txid: "fake_hash",
                           rid: 'fake_address',
                           blockchain_key: 'btc-testnet',
                           sum: 1,
                           type: Withdraws::Coin,
                           aasm_state: :confirming)
        end

        let!(:tx) { Transaction.create(txid: withdrawal.txid, reference: withdrawal, kind: 'tx', from_address: 'fake_address', to_address: withdrawal.rid, blockchain_key: withdrawal.blockchain_key, status: :pending, currency_id: withdrawal.currency_id) }

        let!(:transaction) do
          Peatio::Transaction.new(hash: 'fake_hash', to_address: 'fake_address', amount: 1, block_number: block_number, fee: 0.1, fee_currency_id: currency.id, currency_id: currency.id, txout: 10, status: 'pending')
        end

        let!(:succeed_transaction) do
          Peatio::Transaction.new(hash: 'fake_hash', to_address: 'fake_address', from_addresses: ['fake_address'], amount: 1, block_number: block_number, fee: 0.01, fee_currency_id: currency.id, currency_id: currency.id, txout: 10, status: 'success')
        end

        let(:expected_block) { Peatio::Block.new(block_number, [transaction]) }

        before do
          service.adapter.stubs(:fetch_block!).returns(expected_block)
          service.adapter.stubs(:fetch_transaction).with(transaction).returns(succeed_transaction)
        end

        it 'detects successfuly in the block' do
          expect(Withdraws::Coin.find_by(currency: currency, txid: transaction.hash).succeed?).to be false

          api_post '/api/v2/admin/blockchains/process_block', token: token, params: { block_number: block_number, id: blockchain.id }
          expect(response).to be_successful
          expect(Withdraws::Coin.find_by(currency: currency, txid: transaction.hash).succeed?).to be true
        end
      end
    end
  end
end
