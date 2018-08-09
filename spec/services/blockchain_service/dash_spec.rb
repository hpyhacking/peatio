# encoding: UTF-8
# frozen_string_literal: true

describe BlockchainService::Dash do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'BlockchainClient::Dash' do
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'dash-data', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:transaction_data) do
      Rails.root.join('spec', 'resources', 'dash-data', transaction_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['result']['height'] }
    let(:latest_block)  { block_data.last['result']['height'] }

    let(:blockchain) do
      Blockchain.find_by_key('dash-testnet')
        .tap { |b| b.update(height: start_block) }
    end

    let(:client) { BlockchainClient[blockchain.key] }

    def request_block_hash_body(block_height)
      { jsonrpc: '1.0',
        method: :getblockhash,
        params:  [block_height]
      }.to_json
    end

    def request_block_body(block_hash)
      { jsonrpc: '1.0',
        method:  :getblock,
        params:  [block_hash, true]
      }.to_json
    end

    def request_raw_transaction_body(txid)
      { jsonrpc: '1.0',
        method:  :getrawtransaction,
        params:  [txid, true]
      }.to_json
    end

    context 'one DASH deposit was created during blockchain proccessing' do
      # File with real json rpc data for two blocks.
      let(:block_file_name) { '193257-193258.json' }
      let(:transaction_file_name) { 'raw_transactions/193257-193258.json' }

      let(:expected_deposits) do
        [
          {
            amount:   1026.14160000,
            address:  'yeFUTeA4FzS5UhvDNDCSN4vsy98edjSHq4',
            txid:     'd14317728566e012f18bc9e691639cbe425b181c4339eae2773e0e0c0bc83afd'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:dash) }

      let!(:payment_address) do
        create(:dash_payment_address, address: 'yeFUTeA4FzS5UhvDNDCSN4vsy98edjSHq4')
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)

        block_data.each_with_index do |blk, index|
          # stub get_block_hash
          stub_request(:post, client.endpoint)
            .with(body: request_block_hash_body(blk['result']['height']))
            .to_return(body: {result: blk['result']['hash']}.to_json)

          # stub get_block
          stub_request(:post, client.endpoint)
            .with(body: request_block_body(blk['result']['hash']))
            .to_return(body: blk.to_json)
        end

        transaction_data.each_with_index do |tx, index|
          # stub get_block_hash
          stub_request(:post, client.endpoint)
            .with(body: request_raw_transaction_body(tx['result']['txid']))
            .to_return(body: tx.to_json)
        end

        # Process blockchain data.
        BlockchainService[blockchain.key].process_blockchain(force: true)
      end

      subject { Deposits::Coin.where(currency: currency) }

      it 'creates one deposit' do
        expect(Deposits::Coin.where(currency: currency).count).to eq expected_deposits.count
      end

      it 'creates deposits with correct attributes' do
        expected_deposits.each do |expected_deposit|
          expect(subject.where(expected_deposit).count).to eq 1
        end
      end

      context 'we process same data one more time' do
        before do
          blockchain.update(height: start_block)
        end

        it 'doesn\'t change deposit' do
          expect(blockchain.height).to eq start_block
          expect{ BlockchainService[blockchain.key].process_blockchain(force: true)}.not_to change{subject}
        end
      end
    end

    context 'one DASH withdrawal is processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '193265-193267.json' }
      let(:transaction_file_name) { 'raw_transactions/193265-193267.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_withdrawals) do
        [
          {
            sum:  20.00000000 + currency.withdraw_fee,
            rid:  'yQu2mY8WuXFQmjPBuzkEQ9z1DrhGBSrLL4',
            txid: 'f974214f2bfc6e601dc070970ec4bdbf2ed552bd5ec7fa9f5f8a56d3efbd0ec0'
          }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:dash_account) { member.get_account(:dash).tap { |a| a.update!(locked: 30, balance: 70) } }

      let!(:withdrawals) do
        expected_withdrawals.each_with_object([]) do |withdrawal_hash, withdrawals|
          withdrawal_hash.merge!\
            member: member,
            account: dash_account,
            aasm_state: :confirming,
            currency: currency
          withdrawals << create(:dash_withdraw, withdrawal_hash)
        end
      end

      let(:currency) { Currency.find_by_id(:dash) }

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)

        block_data.each_with_index do |blk, index|
          # stub get_block_hash
          stub_request(:post, client.endpoint)
            .with(body: request_block_hash_body(blk['result']['height']))
            .to_return(body: {result: blk['result']['hash']}.to_json)

          # stub get_block
          stub_request(:post, client.endpoint)
            .with(body: request_block_body(blk['result']['hash']))
            .to_return(body: blk.to_json)
        end

        transaction_data.each_with_index do |tx, index|
          # stub get_block_hash
          stub_request(:post, client.endpoint)
            .with(body: request_raw_transaction_body(tx['result']['txid']))
            .to_return(body: tx.to_json)
        end

        BlockchainService[blockchain.key].process_blockchain(force: true)
      end

      subject { Withdraws::Coin.where(currency: currency) }

      it 'doesn\'t create new withdrawals' do
        expect(subject.count).to eq expected_withdrawals.count
      end

      it 'changes withdraw confirmations amount' do
        subject.each do |withdrawal|
          expect(withdrawal.confirmations).to_not eq 0
        end
      end

      it 'changes withdraw state if it has enough confirmations' do
        subject.each do |withdrawal|
          if withdrawal.confirmations >= blockchain.min_confirmations
            expect(withdrawal.aasm_state).to eq 'succeed'
          end
        end
      end
    end
  end
end
