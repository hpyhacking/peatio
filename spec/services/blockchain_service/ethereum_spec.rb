# encoding: UTF-8
# frozen_string_literal: true

describe BlockchainService::Ethereum do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'Client::Ethereum' do
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'ethereum-data', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:transaction_receipt_data) do
      Rails.root.join('spec', 'resources', 'ethereum-data/transaction-receipts', block_file_name)
          .yield_self { |file_path| File.open(file_path) }
          .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['result']['number'].hex }
    let(:latest_block)  { block_data.last['result']['number'].hex }

    let(:blockchain) do
      Blockchain.find_by_key('eth-rinkeby')
        .tap { |b| b.update(height: start_block) }
    end

    let(:client) { BlockchainClient[blockchain.key] }

    def request_receipt_body(txid, index)
      { jsonrpc: '2.0',
        id:      1,
        method:  :eth_getTransactionReceipt,
        params:  [txid]
      }.to_json
    end

    def request_body(block_number, index)
      { jsonrpc: '2.0',
        id:      1,
        method:  :eth_getBlockByNumber,
        params:  [block_number, true]
      }.to_json
    end

    context 'single ETH deposit was created during blockchain proccessing' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '2621839-2621843.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_deposits) do
        [
          {
            amount:   '0xde0b6b3a7640000'.hex.to_d / currency.base_factor,
            address:  '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa',
            txid:     '0xb60e22c6eed3dc8cd7bc5c7e38c50aa355c55debddbff5c1c4837b995b8ee96d'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:eth) }

      let!(:payment_address) do
        create(:eth_payment_address, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa')
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        block_data.each_with_index do |blk, index|
          stub_request(:post, client.endpoint)
            .with(body: request_body(blk['result']['number'],index))
            .to_return(body: blk.to_json)
        end

        transaction_receipt_data.each_with_index do |rcpt, index|
          stub_request(:post, client.endpoint)
            .with(body: request_receipt_body(rcpt['result']['transactionHash'],index))
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

    context 'two TRST deposits were created during blockchain proccessing' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '2621839-2621843.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_deposits) do
        [
          {
            amount:   '0x1e8480'.hex.to_d / currency.base_factor,
            address:  '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa',
            txid:     '0xd5cc0d1d5dd35f4b57572b440fb4ef39a4ab8035657a21692d1871353bfbceea'
          },
          {
            amount:   '0x1e8480'.hex.to_d / currency.base_factor,
            address:  '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa',
            txid:     '0x826555325cec51c4d39b327e563ce3e8ee87e27be5911383f528724a62f0da5d'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:trst) }

      let!(:payment_address) do
        create(:trst_payment_address, address: '0xe3cb6897d83691a8eb8458140a1941ce1d6e6daa')
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        block_data.each_with_index do |blk, index|
          stub_request(:post, client.endpoint)
            .with(body: request_body(blk['result']['number'], index))
            .to_return(body: blk.to_json)
        end

        transaction_receipt_data.each_with_index do |rcpt, index|
          stub_request(:post, client.endpoint)
              .with(body: request_receipt_body(rcpt['result']['transactionHash'],index))
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

    context 'three ETH withdrawals were processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '2621895-2621903.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_withdrawals) do
        [
          {
            sum:  '0x14d1120d7b160000'.hex.to_d / currency.base_factor + currency.withdraw_fee,
            rid:  '0xb3ebc7b5b631e8d145f383c8cd07f0f00dd56a30',
            txid: '0x643ff4da78faca97454766d9c2a1d455c19083591c87013740acc60286d6dd80'
          },
          {
            sum:  '0xde0b6b3a7640000'.hex.to_d / currency.base_factor + currency.withdraw_fee,
            rid:  '0xb3ebc7b5b631e8d145f383c8cd07f0f00dd56a30',
            txid: '0x5d7f014e7f64c1a8010e64e1f6b6d52efa9c78bb113615bf97d60f30c9cd290b'
          },
          {
            sum:  '0xde0b6b3a7640000'.hex.to_d / currency.base_factor + currency.withdraw_fee,
            rid:  '0xb3ebc7b5b631e8d145f383c8cd07f0f00dd56a30',
            txid: '0x66516a32e90c22a8104b3a3ec2d533efdfcfc004166aa05b555237a4aded99ad'
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
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        block_data.each_with_index do |blk, index|
          stub_request(:post, client.endpoint)
            .with(body: request_body(blk['result']['number'], index))
            .to_return(body: blk.to_json)
        end

        transaction_receipt_data.each_with_index do |rcpt, index|
          stub_request(:post, client.endpoint)
              .with(body: request_receipt_body(rcpt['result']['transactionHash'],index))
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

    context 'two TRST withdrawal is processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '2621895-2621903.json' }

      let(:expected_withdrawals) do
        [
            {
                sum:  0.0005 + currency.withdraw_fee,
                rid:  '0xb3ebc7b5b631e8d145f383c8cd07f0f00dd56a30',
                txid: '0xf3605c58b3a43bc048d58dcc2e49548930f6d2a2927fb098f1d17a03ee599d95'
            },
            {
                sum:  0.0005 + currency.withdraw_fee,
                rid:  '0xfb410459854d10622c45cf242247f368ce49b90c',
                txid: '0xa44a641b57f8d50c89e5ab8e9ce4bac97f42ff2ce7f79e8f5451b379c8a65f93'
            }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:trst_account) { member.get_account(:trst).tap { |a| a.update!(locked: 10, balance: 50) } }

      let(:currency) { Currency.find_by_id(:trst) }

      let!(:failed_withdraw) do
        withdraw_hash = expected_withdrawals[0].merge!\
            member: member,
            account: trst_account,
            aasm_state: :confirming,
            currency: currency

        create(:trst_withdraw, withdraw_hash)
      end

      let!(:success_withdraw) do
        withdraw_hash = expected_withdrawals[1].merge!\
            member: member,
            account: trst_account,
            aasm_state: :confirming,
            currency: currency

        create(:trst_withdraw, withdraw_hash)
      end

      before do
        # Mock requests and methods.
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block)
        client.class.any_instance.stubs(:rpc_call_id).returns(1)

        block_data.each_with_index do |blk, index|
          stub_request(:post, client.endpoint)
              .with(body: request_body(blk['result']['number'], index))
              .to_return(body: blk.to_json)
        end

        transaction_receipt_data.each_with_index do |rcpt, index|
          stub_request(:post, client.endpoint)
              .with(body: request_receipt_body(rcpt['result']['transactionHash'],index))
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
