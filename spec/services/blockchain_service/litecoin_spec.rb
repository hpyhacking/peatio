# encoding: UTF-8
# frozen_string_literal: true

describe BlockchainService::Litecoin do

  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'BlockchainClient::Litecoin' do
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'litecoin-data', block_file_name)
        .yield_self { |file_path| File.open(file_path) }
        .yield_self { |file| JSON.load(file) }
    end

    let(:start_block)   { block_data.first['result']['height'] }
    let(:latest_block)  { block_data.last['result']['height'] }

    let(:blockchain) do
      Blockchain.find_by_key('ltc-testnet')
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
        params:  [block_hash, 2]
      }.to_json
    end

    context 'One LTC deposit was created during blockchain proccessing' do
      # File with real json rpc data for two blocks.
      let(:block_file_name) { '678768-678769.json' }

      let(:expected_deposits) do
        [
          {
            amount:   10.00000000,
            address:  'QaXKfMcHj86a9AQh2YTAkkhMEJuN6dfuyu',
            txid:     '72bdd063443f991cf949cb7a8061791ebde7d707b76ee8f28a4eab2158d88166'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:ltc) }

      let!(:payment_address) do
        create(:ltc_payment_address, address: 'QaXKfMcHj86a9AQh2YTAkkhMEJuN6dfuyu')
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

    context 'two LTC withdrawals were processed' do
      # File with real json rpc data for bunch of blocks.
      let(:block_file_name) { '678947-678948.json' }

      # Use rinkeby.etherscan.io to fetch transactions data.
      let(:expected_withdrawals) do
        [
          {
            sum:  3.00000000 + currency.withdraw_fee,
            rid:  'QUwDTFe1H7EAChVqm6FXexC8YpLPxc2U6n',
            txid: 'bd75341b46132bba6805f6494871db4b42db972ac4643c1c2cf249797a114035'
          },
          {
            sum:  5.00000000 + currency.withdraw_fee,
            rid:  'QUwDTFe1H7EAChVqm6FXexC8YpLPxc2U6n',
            txid: '77aea3faa3c5d97fe75736a4171e88bd1519893b45f39490d25d7b0c932c356c'
          }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:ltc_account) { member.get_account(:ltc).tap { |a| a.update!(locked: 10, balance: 50) } }

      let!(:withdrawals) do
        expected_withdrawals.each_with_object([]) do |withdrawal_hash, withdrawals|
          withdrawal_hash.merge!\
            member: member,
            account: ltc_account,
            aasm_state: :confirming,
            currency: currency
          withdrawals << create(:ltc_withdraw, withdrawal_hash)
        end
      end

      let(:currency) { Currency.find_by_id(:ltc) }

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
