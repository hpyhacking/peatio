# encoding: UTF-8
# frozen_string_literal: true

class FakeBlockchain < Peatio::Blockchain::Abstract
  def initialize
    @features = {cash_addr_format: false, case_sensitive: true}
  end

  def configure(settings = {}); end
end

describe BlockchainService do

  let!(:blockchain) { create(:blockchain, 'fake-testnet') }
  let(:block_number) { 100 }
  let(:fake_adapter) { FakeBlockchain.new }
  let(:service) { BlockchainService.new(blockchain) }

  let!(:fake_currency) { create(:currency, :fake) }
  let!(:fake_currency1) { create(:currency, :fake, id: 'fake1') }
  let!(:fake_currency2) { create(:currency, :fake, id: 'fake2') }
  let!(:wallet) { create(:wallet, :fake_deposit) }

  let!(:member) { create(:member) }

  let(:transaction) { Peatio::Transaction.new(hash: 'fake_txid', to_address: 'fake_address', from_addresses: ['fake_address'], amount: 5, block_number: 3, currency_id: 'fake1', txout: 4, status: 'success') }

  let(:expected_transactions) do
    [
      { hash: 'fake_hash1', to_address: 'fake_address', amount: 1, block_number: 2, currency_id: 'fake1', txout: 1, from_addresses: ['fake_address'], status: 'success' },
      { hash: 'fake_hash2', to_address: 'fake_address1', amount: 2, block_number: 2, currency_id: 'fake1', txout: 2, from_addresses: ['fake_address'], status: 'success' },
      { hash: 'fake_hash3', to_address: 'fake_address2', amount: 3, block_number: 2, currency_id: 'fake2', txout: 3, from_addresses: ['fake_address'], status: 'success' }
    ].map { |t| Peatio::Transaction.new(t) }
  end

  let(:expected_block) { Peatio::Block.new(block_number, expected_transactions) }

  before do
    wallet.currencies << [fake_currency1, fake_currency2]
    Peatio::Blockchain.registry.expects(:[])
                         .with(:fake)
                         .returns(fake_adapter.class)
                         .at_least_once

    service.stubs(:latest_block_number).returns(4)
    service.adapter.stubs(:latest_block_number).never
  end

  # Deposit context: (mock fetch_block)
  #   * Single deposit in block which should be saved.
  #   * Multiple deposits in single block (one saved one updated).
  #   * Multiple deposits for 2 currencies in single block.
  #   * Multiple deposits in single transaction (different txout).
  describe 'Filter Deposits' do

    context 'single fake deposit was created during block processing' do

      before do
        PaymentAddress.create!(member: member,
                               wallet: wallet,
                               address: 'fake_address')
        service.adapter.stubs(:fetch_block!).returns(expected_block)
        service.process_block(block_number)
      end

      subject { Deposits::Coin.where(currency: fake_currency1) }

      it { expect(subject.exists?).to be true }

      context 'creates deposit with correct attributes' do
        before do
          service.adapter.stubs(:fetch_block!).returns(Peatio::Block.new(block_number, [transaction]))
          service.process_block(block_number)
        end

        it { expect(subject.where(txid: transaction.hash,
                        amount: transaction.amount,
                        address: transaction.to_address,
                        block_number: transaction.block_number,
                        txout: transaction.txout,
                        from_addresses: transaction.from_addresses).exists?).to be true }
      end

      context 'collect deposit after processing block' do
        before do
          service.stubs(:latest_block_number).returns(100)
          service.adapter.stubs(:fetch_block!).returns(expected_block)
          AMQP::Queue.expects(:enqueue).with(:events_processor, is_a(Hash))
        end

        it { service.process_block(block_number) }
      end

      context 'process data one more time' do
        before do
          service.adapter.stubs(:fetch_block!).returns(expected_block)
        end

        it { expect { service.process_block(block_number) }.not_to change { subject } }
      end
    end

    context 'two fake deposits for one currency were created during block processing' do
      before do
        PaymentAddress.create!(member: member,
                               wallet: wallet,
                               address: 'fake_address')
        PaymentAddress.create!(member: member,
                               wallet: wallet,
                               address: 'fake_address1')
        service.adapter.stubs(:fetch_block!).returns(expected_block)
        service.process_block(block_number)
      end

      subject { Deposits::Coin.where(currency: fake_currency1) }

      it { expect(subject.count).to eq 2 }

      context 'one deposit was updated' do
        let!(:deposit) do
          Deposit.create!(currency: fake_currency1,
                          member: member,
                          amount: 5,
                          address: 'fake_address',
                          txid: 'fake_txid',
                          block_number: 0,
                          txout: 4,
                          type: Deposits::Coin)
        end
        before do
          service.adapter.stubs(:fetch_block!).returns(Peatio::Block.new(block_number, [transaction]))
          service.process_block(block_number)
        end
        it { expect(Deposits::Coin.find_by(txid: transaction.hash).block_number).to eq(transaction.block_number) }
      end
    end

    context 'two fake deposits for two currency were created during block processing' do
      before do
        PaymentAddress.create!(member: member,
                               wallet: wallet,
                               address: 'fake_address')
        PaymentAddress.create!(member: member,
                               wallet: wallet,
                               address: 'fake_address2')
        service.adapter.stubs(:fetch_block!).returns(expected_block)
        service.process_block(block_number)
      end

      subject { Deposits::Coin.where(currency: [fake_currency1, fake_currency2]) }

      it do
        expect(subject.count).to eq 2
        expect(Deposits::Coin.where(currency: fake_currency1).exists?).to be true
        expect(Deposits::Coin.where(currency: fake_currency2).exists?).to be true
      end
    end

    context 'skip deposit collection fee transaction' do
      let!(:transaction) { create(:transaction, txid: 'fake_hash1') }
      before do
        PaymentAddress.create!(member: member,
                               wallet: wallet,
                               address: 'fake_address')
        service.adapter.stubs(:fetch_block!).returns(expected_block)
        service.process_block(block_number)
      end

      subject { Deposits::Coin.where(currency: [fake_currency1, fake_currency2]) }

      it do
        expect(subject.count).to eq 1
      end
    end
  end

  # Withdraw context: (mock fetch_block)
  #   * Single withdrawal.
  #   * Multiple withdrawals for single currency.
  #   * Multiple withdrawals for 2 currencies.
  describe 'Filter Withdrawals' do

    context 'single fake withdrawal was updated during block processing' do

      let!(:fake_account) { member.get_account(:fake1).tap { |ac| ac.update!(balance: 50, locked: 5) } }
      let!(:withdrawal) do
        Withdraw.create!(member: member,
                         currency: fake_currency1,
                         amount: 1,
                         txid: 'fake_hash1',
                         rid: 'fake_address',
                         sum: 1,
                         type: Withdraws::Coin,
                         aasm_state: :confirming)
      end

      before do
        service.adapter.stubs(:fetch_block!).returns(expected_block)
        service.process_block(block_number)
      end

      it { expect(withdrawal.reload.block_number).to eq(expected_transactions.first.block_number) }

      context 'single withdrawal was succeed during block processing' do

        before do
          service.stubs(:latest_block_number).returns(100)
          service.adapter.stubs(:fetch_block!).returns(expected_block)
          service.process_block(block_number)
        end

        it { expect(withdrawal.reload.succeed?).to be true }
      end
    end
  end

  context 'two fake withdrawals were updated during block processing' do

    let!(:fake_account1) { member.get_account(:fake1).tap { |ac| ac.update!(balance: 50, locked: 10) } }
    let!(:withdrawals) do
      %w[fake_hash1 fake_hash2].each do |t|
        Withdraw.create!(member: member,
                         currency: fake_currency1,
                         amount: 1,
                         txid: t,
                         rid: 'fake_address',
                         sum: 1,
                         type: Withdraws::Coin,
                         aasm_state: :confirming)
      end
    end

    before do
      service.adapter.stubs(:fetch_block!).returns(expected_block)
      service.process_block(block_number)
    end

    subject { Withdraws::Coin.where(currency: fake_currency1) }

    it do
      expect(subject.find_by(txid: expected_transactions.first.hash).block_number).to eq(expected_transactions.first.block_number)
      expect(subject.find_by(txid: expected_transactions.second.hash).block_number).to eq(expected_transactions.second.block_number)
    end
  end

  context 'two fake withdrawals for two currency were updated during block processing' do
    let!(:fake_account1) { member.get_account(:fake1).tap { |ac| ac.update!(balance: 50, locked: 10) } }
    let!(:fake_account2) { member.get_account(:fake2).tap { |ac| ac.update!(balance: 50, locked: 10) } }
    let!(:withdrawal1) do
      Withdraw.create!(member: member,
                       currency: fake_currency1,
                       amount: 1,
                       txid: "fake_hash1",
                       rid: 'fake_address',
                       sum: 1,
                       type: Withdraws::Coin,
                       aasm_state: :confirming)
    end
    let!(:withdrawal2) do
      Withdraw.create!(member: member,
                        currency: fake_currency2,
                        amount: 1,
                        txid: "fake_hash3",
                        rid: 'fake_address',
                        sum: 1,
                        type: Withdraws::Coin,
                        aasm_state: :confirming)
    end

    before do
      service.adapter.stubs(:fetch_block!).returns(expected_block)
      service.process_block(block_number)
    end

    subject { Withdraws::Coin.where(currency: [fake_currency1, fake_currency2]) }

    it do
      expect(subject.find_by(txid: expected_transactions.first.hash).block_number).to eq(expected_transactions.first.block_number)
      expect(subject.find_by(txid: expected_transactions.third.hash).block_number).to eq(expected_transactions.third.block_number)
    end

    context 'fail withdrawal if transaction has status :fail' do

      let!(:fake_account1) { member.get_account(:fake1).tap { |ac| ac.update!(balance: 50, locked: 10) } }

      let!(:withdrawal) do
        Withdraw.create!(member: member,
                         currency: fake_currency1,
                         amount: 1,
                         txid: "fake_hash",
                         rid: 'fake_address',
                         sum: 1,
                         type: Withdraws::Coin,
                         aasm_state: :confirming)
      end

      let!(:transaction) do
        Peatio::Transaction.new(hash: 'fake_hash', to_address: 'fake_address', amount: 1, block_number: 3, currency_id: fake_currency1.id, txout: 10, status: 'failed')
      end

      before do
        service.adapter.stubs(:fetch_block!).returns(Peatio::Block.new(block_number, [transaction]))
        service.process_block(block_number)
      end

      subject { Withdraws::Coin.find_by(currency: fake_currency1, txid: transaction.hash) }

      it do
        expect(subject.failed?).to be true
      end
    end

    context 'fail withdrawal if transaction has status :fail' do

      let!(:fake_account1) { member.get_account(:fake1).tap { |ac| ac.update!(balance: 50, locked: 10) } }

      let!(:withdrawal) do
        Withdraw.create!(member: member,
                         currency: fake_currency1,
                         amount: 1,
                         txid: "fake_hash",
                         rid: 'fake_address',
                         sum: 1,
                         type: Withdraws::Coin,
                         aasm_state: :confirming)
      end

      let!(:transaction) do
        Peatio::Transaction.new(hash: 'fake_hash', to_address: 'fake_address', amount: 1, block_number: 3, currency_id: fake_currency1.id, txout: 10, status: 'pending')
      end

      let!(:failed_transaction) do
        Peatio::Transaction.new(hash: 'fake_hash', to_address: 'fake_address', amount: 1, block_number: 3, currency_id: fake_currency1.id, txout: 10, status: 'failed')
      end

      before do
        service.adapter.stubs(:respond_to?).returns(true)
        service.adapter.stubs(:fetch_block!).returns(Peatio::Block.new(block_number, [transaction]))
        service.adapter.stubs(:fetch_transaction).with(transaction).returns(failed_transaction)
        service.process_block(block_number)
      end

      subject { Withdraws::Coin.find_by(currency: fake_currency1, txid: transaction.hash) }

      it do
        expect(subject.failed?).to be true
      end
    end

    context 'succeed withdrawal if transaction has status :success' do

      let!(:fake_account1) { member.get_account(:fake1).tap { |ac| ac.update!(balance: 50, locked: 10) } }

      let!(:withdrawal) do
        Withdraw.create!(member: member,
                         currency: fake_currency1,
                         amount: 1,
                         txid: "fake_hash",
                         rid: 'fake_address',
                         sum: 1,
                         type: Withdraws::Coin,
                         aasm_state: :confirming)
      end

      let!(:transaction) do
        Peatio::Transaction.new(hash: 'fake_hash', to_address: 'fake_address', amount: 1, block_number: 3, currency_id: fake_currency1.id, txout: 10, status: 'pending')
      end

      let!(:succeed_transaction) do
        Peatio::Transaction.new(hash: 'fake_hash', to_address: 'fake_address', amount: 1, block_number: 3, currency_id: fake_currency1.id, txout: 10, status: 'success')
      end

      before do
        service.adapter.stubs(:respond_to?).returns(true)
        service.adapter.stubs(:fetch_block!).returns(Peatio::Block.new(block_number, [transaction]))
        service.stubs(:latest_block_number).returns(10)
        service.adapter.stubs(:fetch_transaction).with(transaction).returns(succeed_transaction)
        service.process_block(block_number)
      end

      subject { Withdraws::Coin.find_by(currency: fake_currency1, txid: transaction.hash) }

      it do
        expect(subject.succeed?).to be true
      end
    end
  end

  describe 'Several blocks' do
    let(:expected_transactions1) do
      [
        { hash: 'fake_hash4', to_address: 'fake_address4', amount: 1, block_number: 3, currency_id: 'fake1', txout: 1, status: 'success' },
        { hash: 'fake_hash5', to_address: 'fake_address4', amount: 2, block_number: 3, currency_id: 'fake1', txout: 2, status: 'success' },
        { hash: 'fake_hash6', to_address: 'fake_address4', amount: 3, block_number: 3, currency_id: 'fake2', txout: 1, status: 'success' }
      ].map { |t| Peatio::Transaction.new(t) }
    end

    let(:expected_block1) { Peatio::Block.new(block_number, expected_transactions1) }

    let!(:fake_account1) { member.get_account(:fake1) }
    let!(:fake_account2) { member.get_account(:fake2) }

    before do
      service.stubs(:latest_block_number).returns(100)
      PaymentAddress.create!(member: member,
                             wallet: wallet,
                             address: 'fake_address')
      PaymentAddress.create!(member: member,
                             wallet: wallet,
                             address: 'fake_address2')
      service.adapter.stubs(:fetch_block!).returns(expected_block, expected_block1)
    end

    it 'creates deposits and updates withdrawals' do
      service.process_block(block_number)
      expect(Deposits::Coin.where(currency: fake_currency1).exists?).to be true
      expect(Deposits::Coin.where(currency: fake_currency2).exists?).to be true
      Deposit.find_each { |d| d.dispatch! }

      [fake_account1, fake_account2].map { |a| a.reload }
      withdraw1 = Withdraw.create!(member: member, currency: fake_currency1, amount: 1, txid: "fake_hash5",
        rid: 'fake_address4', sum: 1, type: Withdraws::Coin)
      withdraw1.accept!
      withdraw1.process!
      withdraw1.dispatch!

      withdraw2 = Withdraw.create!(member: member, currency: fake_currency2, amount: 3, txid: "fake_hash6",
        rid: 'fake_address4', sum: 3, type: Withdraws::Coin)
      withdraw2.accept!
      withdraw2.process!
      withdraw2.dispatch!

      service.process_block(block_number)
      expect(withdraw1.reload.succeed?).to be true
      expect(withdraw2.reload.succeed?).to be true
    end
  end
end
