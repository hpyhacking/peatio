# frozen_string_literal: true

describe BlockchainService::Ripple do
  around do |example|
    WebMock.disable_net_connect!
    example.run
    WebMock.allow_net_connect!
  end

  describe 'Client::Ripple' do
    let(:block_data) do
      Rails.root.join('spec', 'resources', 'ripple-data', '40280751-40280751.json')
           .yield_self { |file_path| File.open(file_path) }
           .yield_self { |file| JSON.load(file) }
    end

    let(:start_ledger_index) { block_data['result']['ledger']['ledger_index'].to_i }
    let(:latest_block_number) { start_ledger_index }

    let(:client) { BlockchainClient[blockchain.key] }
    let(:process_blockchain) do
      BlockchainService[blockchain.key].process_blockchain(force: true)
    end
    let(:blockchain) do
      Blockchain.find_by_key('xrp-testnet')
                .tap { |b| b.update(height: start_ledger_index) }
    end

    def request_body(ledger_index, index)
      {
        jsonrpc: '1.0',
        id: index + 1,
        method: :ledger,
        params: [{
          ledger_index: ledger_index,
          transactions: true,
          expand: true
        }]
      }.to_json
    end

    context 'single XRP withdrawal was created during blockchain proccessing' do
      let(:latest_block_number) { start_ledger_index + confirmations }
      let(:confirmations) { 1 }
      let(:expected_withdrawals) do
        [
          {
            sum:  131.6506 + currency.withdraw_fee,
            rid:  'rhL5Va5tDbUUuozS9isvEuv7Uk1uuJaY1T',
            txid: 'C63F87647D3C6EB647D0AC50357ED1C7E598525F64158AFAF9F7FF44EF9B7D86'
          }
        ]
      end

      let(:member) { create(:member, :level_3, :barong) }
      let!(:xrp_account) do
        member.get_account(:xrp)
              .tap { |a| a.update!(locked: 150, balance: 500) }
      end

      let!(:withdrawals) do
        expected_withdrawals.each_with_object([]) do |withdrawal_hash, withdrawals|
          withdrawals << create(:xrp_withdraw, withdrawal_hash.merge(
                                                 member: member,
                                                 account: xrp_account,
                                                 aasm_state: :confirming,
                                                 currency: currency
                                               ))
        end
      end

      let(:currency) { Currency.find_by_id(:xrp) }

      before do
        client.class.any_instance.stubs(:latest_block_number)
                    .returns(latest_block_number)
        stub_request(:post, client.endpoint)
          .with(body: request_body(start_ledger_index, 0))
          .to_return(body: block_data.to_json)
        stub_request(:post, client.endpoint)
          .with(body: request_body(start_ledger_index + 1, 1))
          .to_return(body: {}.to_json)
      end

      subject { Withdraws::Coin.where(currency: currency) }

      it "doesn't create new withdrawals" do
        process_blockchain
        expect(subject.count).to eq expected_withdrawals.count
      end

      it 'changes withdraw confirmations amount' do
        process_blockchain
        subject.each do |withdrawal|
          expect(withdrawal.reload.aasm_state).to eq 'succeed'
          expect(withdrawal.reload.confirmations).to eq confirmations
        end
      end
    end

    context 'single XRP deposit was created during blockchain proccessing' do
      let(:expected_deposits) do
        [
          {
            amount:   1481.213099,
            address:  'rLW9gnQo7BQhU6igk5keqYnH3TVrCxGRzm?dt=442374800',
            txid:     '9C606146E70ECD39BA4EC008A6933A228EB014025D13D9023967212D8095DA07'
          }
        ]
      end

      let(:currency) { Currency.find_by_id(:xrp) }

      let!(:payment_address) do
        create(:xrp_payment_address, address: 'rLW9gnQo7BQhU6igk5keqYnH3TVrCxGRzm?dt=442374800')
      end

      before do
        client.class.any_instance.stubs(:latest_block_number).returns(latest_block_number)
        stub_request(:post, client.endpoint)
          .with(body: request_body(start_ledger_index, 0))
          .to_return(body: block_data.to_json)
      end

      subject { Deposits::Coin.where(currency: currency) }

      it 'creates single deposit' do
        process_blockchain
        expect(subject.count).to eq expected_deposits.count
      end

      it 'creates deposits with correct attributes' do
        process_blockchain
        expected_deposits.each do |expected_deposit|
          expect(subject.where(expected_deposit).count).to eq 1
        end
      end

      context 'we process same data one more time' do
        before do
          blockchain.update(height: start_ledger_index)
        end

        it 'doesn\'t change deposit' do
          expect { process_blockchain }.not_to change { subject }
        end
      end
    end
  end
end
