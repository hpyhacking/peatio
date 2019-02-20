# encoding: UTF-8
# frozen_string_literal: true

describe BlockchainService::Parity do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'Client::Parity' do
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'ethereum-data', 'kovan', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:transaction_receipt_data) do
        Rails.root.join('spec', 'resources', 'ethereum-data', 'kovan/transaction-receipts', block_file_name)
          .yield_self { |file_path| File.open(file_path) }
          .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['result']['number'].hex }
    let(:latest_block)  { block_data.last['result']['number'].hex }

    let(:blockchain) do
      Blockchain.find_by_key('eth-kovan')
        .tap { |b| b.update(height: start_block) }
    end

    let(:client) { BlockchainClient[blockchain.key] }

    def request_receipt_body(txid)
      { jsonrpc: '2.0',
        id:      1,
        method:  :eth_getTransactionReceipt,
        params:  [txid] }.to_json
    end

    def request_body(block_number)
      { jsonrpc: '2.0',
        id:      1,
        method:  :eth_getBlockByNumber,
        params:  [block_number, true] }.to_json
    end

    context 'single ETH deposit was created during blockchain proccessing' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '9000003-9000006.json' }

      let(:expected_deposits) do
        [
          {
            amount:   '0x29a2241af62c0000'.hex.to_d / currency.base_factor,
            address:  '0x8daa2b5d364cf3761a025f0005d55bd83ef4716f',
            txid:     '0x70f1aa055b0547e216268c83a56ba7769c3ebb1ab023b85233efcf8e0a4efd90'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:eth) }

      let!(:payment_address) do
        create(:eth_payment_address, address: '0x8daa2b5d364cf3761a025f0005d55bd83ef4716f')
      end

      before do
        currency.update('blockchain_key': 'eth-kovan')
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        Deposits::Coin.where(currency: currency).delete_all

        block_data.each do |blk|
          stub_request(:post, client.endpoint)
            .with(body: request_body(blk['result']['number']))
            .to_return(body: blk.to_json)
        end

        transaction_receipt_data.each do |rcpt|
          stub_request(:post, client.endpoint)
            .with(body: request_receipt_body(rcpt['result']['transactionHash']))
            .to_return(body: rcpt.to_json)
        end

        # Process blockchain data.
        BlockchainService[blockchain.key].process_blockchain(force: true)
      end

      subject { Deposits::Coin.where(currency: currency) }

      it 'creates single deposit' do
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

    context 'two RING deposits were created during blockchain proccessing' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '9755696-9755698.json' }

      let(:expected_deposits) do
        [
          {
            amount:   '0x1b1ae4d6e2ef500000'.hex.to_d / currency.base_factor,
            address:  '0x23236af7d03c4b0720f709593f5ace0ea92e77ca',
            txid:     '0x86c73840543d46a697052ad8c83be3a0bf120f6062c39bad4087715b521c9c20',
            txout:    1
          },
          {
            amount:   '0x1b1ae4d6e2ef500000'.hex.to_d / currency.base_factor,
            address:  '0x23236af7d03c4b0720f709593f5ace0ea92e77cf',
            txid:     '0x3f7a0e8b9be58f54b0a084bef1a32e10add73c97bf4406689da70cc71765775c',
            txout:    2
           }
        ]
      end

      let(:currency) { Currency.find_by_id(:ring) }

      let!(:payment_address) do
        create(:ring_payment_address, address: '0x23236af7d03c4b0720f709593f5ace0ea92e77cf')
      end

      let!(:second_payment_address) do
        create(:ring_payment_address, address: '0x23236af7d03c4b0720f709593f5ace0ea92e77ca')
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        Deposits::Coin.where(currency: currency).delete_all

        block_data.each do |blk|
          stub_request(:post, client.endpoint)
            .with(body: request_body(blk['result']['number']))
            .to_return(body: blk.to_json)
        end

        transaction_receipt_data.each do |rcpt|
          stub_request(:post, client.endpoint)
              .with(body: request_receipt_body(rcpt['result']['transactionHash']))
              .to_return(body: rcpt.to_json)
        end
        BlockchainService[blockchain.key].process_blockchain(force: true)
      end

      subject { Deposits::Coin.where(currency: currency) }

      it 'creates two deposits' do
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

    context 'two RING deposit in one transaction were created during blockchain proccessing' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '9755696-9755698.json' }

      let(:expected_deposits) do
        [
          {
            amount:   '0x5142cdcdf5268c0000'.hex.to_d / currency.base_factor,
            address:  '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa',
            txid:     '0x647f28bf8a191b70b91b999a28a91669fa6d02f01ddd9c12dbfd15293e0acd63'
          },
          {
            amount:   '0xde0b6b3a7640000'.hex.to_d / currency.base_factor,
            address:  '0x4b6a630ff1f66604d31952bdce2e4950efc99821',
            txid:     '0x647f28bf8a191b70b91b999a28a91669fa6d02f01ddd9c12dbfd15293e0acd63'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:ring) }

      let!(:payment_address) do
        create(:ring_payment_address, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa')
      end

      let!(:second_payment_address) do
        create(:ring_payment_address, address: '0x4b6a630ff1f66604d31952bdce2e4950efc99821')
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        block_data.each do |blk|
          stub_request(:post, client.endpoint)
            .with(body: request_body(blk['result']['number']))
            .to_return(body: blk.to_json)
        end

        transaction_receipt_data.each do |rcpt|
          stub_request(:post, client.endpoint)
              .with(body: request_receipt_body(rcpt['result']['transactionHash']))
              .to_return(body: rcpt.to_json)
        end
        BlockchainService[blockchain.key].process_blockchain(force: true)
      end

      subject { Deposits::Coin.where(currency: currency) }

      it 'creates two deposits' do
        expect(Deposits::Coin.where(currency: currency).count).to eq expected_deposits.count
      end

      it 'creates deposits with correct attributes' do
        expected_deposits.each do |expected_deposit|
          expect(subject.where(expected_deposit).count).to eq 1
        end
      end
    end

    context 'two ETH withdrawals were processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '9669001-9669005.json' }

      let(:expected_withdrawals) do
        [
          {
            sum:  '0xaa87bee538000'.hex.to_d / currency.base_factor + currency.withdraw_fee,
            rid:  '0x31e129134d07ad43fda9e0c3d397c9ad2b3b2637',
            txid: '0xca3f16e57db2d98f1c9007a729ca073f4405ac64d0389961eb4f08eb9164182b'
          },
          {
            sum:  '0xaa87bee538000'.hex.to_d / currency.base_factor + currency.withdraw_fee,
            rid:  '0x12eafeffa3a6685b029a67fab2e80ab020055140',
            txid: '0xe6227270b5816f72a6e4ec687609f8c6bd6862bf78c5a3fec3eb784f93849ead'
          }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:eth_account) { member.get_account(:eth).tap { |a| a.update!(locked: 10, balance: 50) } }

      let!(:withdrawals) do
        expected_withdrawals.each_with_object([]) do |withdrawal_hash, withdrawals|
          withdrawal_hash.merge!\
            member: member,
            account: eth_account,
            aasm_state: :confirming,
            currency: currency
          withdrawals << create(:eth_withdraw, withdrawal_hash)
        end
      end

      let(:currency) { Currency.find_by_id(:eth) }

      before do
        currency.update('blockchain_key': 'eth-kovan')
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        block_data.each do |blk|
          stub_request(:post, client.endpoint)
            .with(body: request_body(blk['result']['number']))
            .to_return(body: blk.to_json)
        end

        transaction_receipt_data.each do |rcpt|
          stub_request(:post, client.endpoint)
              .with(body: request_receipt_body(rcpt['result']['transactionHash']))
              .to_return(body: rcpt.to_json)
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
          if withdrawal.confirmations >= blockchain.min_confirmations
            expect(withdrawal.aasm_state).to eq 'succeed'
          end
        end
      end

      it 'changes withdraw state if it has enough confirmations' do
        subject.each do |withdrawal|
          expect(withdrawal.confirmations).to_not eq 0
          if withdrawal.confirmations >= blockchain.min_confirmations
            expect(withdrawal.aasm_state).to eq 'succeed'
          end
        end
      end
    end

    context 'two RING withdrawal is processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '9755696-9755698.json' }

      let(:expected_withdrawals) do
        [
          {
            sum:  0.0005 + currency.withdraw_fee,
            rid:  '0xecd7a31404e7263c488816ebb329b5bb3f98a431',
            txid: '0x86c73840543d46a697052ad8c83be3a0bf120f6062c39bad4087715b521c9c20'
          },
          {
            sum:  0.0005 + currency.withdraw_fee,
            rid:  '0xecd7a31404e7263c488816ebb329b5bb3f98a431',
            txid: '0x62c2dd800a2e66a6d6d57c630c2ca243fb592f3f49e0f7b49b666da5cdabd543'
          }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:ring_account) { member.get_account(:ring).tap { |a| a.update!(locked: 10, balance: 50) } }

      let(:currency) { Currency.find_by_id(:ring) }

      let!(:failed_withdraw) do
        withdraw_hash = expected_withdrawals[1].merge!\
          member: member,
          account: ring_account,
          aasm_state: :confirming,
          currency: currency

        create(:ring_withdraw, withdraw_hash)
      end

      let!(:success_withdraw) do
        withdraw_hash = expected_withdrawals[0].merge!\
          member: member,
          account: ring_account,
          aasm_state: :confirming,
          currency: currency

        create(:ring_withdraw, withdraw_hash)
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        block_data.each do |blk|
          stub_request(:post, client.endpoint)
              .with(body: request_body(blk['result']['number']))
              .to_return(body: blk.to_json)
        end

        transaction_receipt_data.each do |rcpt|
          stub_request(:post, client.endpoint)
              .with(body: request_receipt_body(rcpt['result']['transactionHash']))
              .to_return(body: rcpt.to_json)
        end
        BlockchainService[blockchain.key].process_blockchain(force: true)
      end

      subject { Withdraws::Coin.where(currency: currency) }

      it 'doesn\'t create new withdrawals' do
        expect(subject.count).to eq expected_withdrawals.count
      end

      it 'changes withdraw state to failed' do
        failed_withdraw.reload
        expect(failed_withdraw.aasm_state).to eq 'failed'
      end

      it 'changes withdraw state to success' do
        success_withdraw.reload
        expect(success_withdraw.confirmations).to_not eq 0
        if success_withdraw.confirmations >= blockchain.min_confirmations
          expect(success_withdraw.aasm_state).to eq 'succeed'
        end
      end
    end
  end
end
