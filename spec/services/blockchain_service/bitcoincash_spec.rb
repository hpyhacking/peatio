# encoding: UTF-8
# frozen_string_literal: true

describe BlockchainService::Bitcoincash do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'BlockchainClient::Bitocoincash' do
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'bitcoincash-data', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:transaction_data) do
      Rails.root.join('spec', 'resources', 'bitcoincash-data', transaction_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['result']['height'] }
    let(:latest_block)  { block_data.last['result']['height'] }

    let(:blockchain) do
      Blockchain.find_by_key('bch-testnet')
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

    context 'two BCH deposit was created during blockchain proccessing' do
      # File with real json rpc data for two blocks.
      let(:block_file_name) { '1248466-1248467.json' }
      let(:transaction_file_name) { 'raw_transactions/1248466-1248467.json' }

      let(:expected_deposits) do
        [
          {
            amount:   2.00000000,
            address:  'bchtest:qqhwkkl7c9lsenyp3wz82mh3cnsvx4xppy08e2m9ta',
            txid:     '5d1037991225ab4c9759dbde71c2450f5c19b18c1715b895197475ba9a986e1e'
          },
          {
            amount:   3.00000000,
            address:  'bchtest:qqhwkkl7c9lsenyp3wz82mh3cnsvx4xppy08e2m9ta',
            txid:     'd64e5e50bcb6d9ec7ecb709ed65819b1768a9029cd0e2b57ff37dd2f81d27855'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:bch) }

      let!(:payment_address) do
        create(:bch_payment_address, address: 'bchtest:qqhwkkl7c9lsenyp3wz82mh3cnsvx4xppy08e2m9ta')
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

    context 'one BCH withdrawal is processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '1248467-1248468.json' }
      let(:transaction_file_name) { 'raw_transactions/1248467-1248468.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_withdrawals) do
        [
          {
            sum:  2.50000000 + currency.withdraw_fee,
            rid:  '2MxjMod4B6KwrySJ6XzxCveEzUreQTJ4M1d',
            txid: '45adbf46ce2aaf9ab92509c02909a0ce20b5b6b48c470756c3a50a164754147e'
          }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:bch_account) { member.get_account(:bch).tap { |a| a.update!(locked: 30, balance: 70) } }

      let!(:withdrawals) do
        expected_withdrawals.each_with_object([]) do |withdrawal_hash, withdrawals|
          withdrawal_hash.merge!\
            member: member,
            account: bch_account,
            aasm_state: :confirming,
            currency: currency
          withdrawals << create(:bch_withdraw, withdrawal_hash)
        end
      end

      let(:currency) { Currency.find_by_id(:bch) }

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
