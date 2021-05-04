# encoding: UTF-8
# frozen_string_literal: true

describe WalletService do
  let!(:blockchain) { create(:blockchain, 'fake-testnet') }
  let!(:currency) { create(:currency, :fake) }
  let(:wallet) { create(:wallet, :fake_hot) }
  let!(:fake_blockchain_currency) { create(:blockchain_currency, :fake_network) }
  let!(:member) { create(:member) }

  let(:fake_wallet_adapter) { FakeWallet.new }
  let(:fake_blockchain_adapter) { FakeBlockchain.new }

  let(:service) { WalletService.new(wallet) }

  before do
    Peatio::Blockchain.registry.expects(:[])
                         .with(:fake)
                         .returns(fake_blockchain_adapter.class)
                         .at_least_once

    Peatio::Wallet.registry.expects(:[])
                     .with(:fake)
                     .returns(fake_wallet_adapter.class)
                     .at_least_once


    Blockchain.any_instance.stubs(:blockchain_api).returns(BlockchainService.new(blockchain))
  end

  context :create_address! do
    let(:account) { create(:member, :level_3, :barong).get_account(currency)  }
    let(:blockchain_address) do
      { address: :fake_address,
        secret: :changeme,
        details: { uid: account.member.uid } }
    end

    before do
      service.adapter.expects(:create_address!).returns(blockchain_address)
    end

    it 'creates address' do
      expect(service.create_address!(account, nil)).to eq blockchain_address
    end
  end

  context :build_withdrawal! do
    let(:withdrawal) { create(:btc_withdraw, rid: 'fake-address', blockchain_key: 'fake-testnet', amount: 100, currency: currency, member: member) }

    let(:transaction) do
      Peatio::Transaction.new(hash:        '0xfake',
                              to_address:  withdrawal.rid,
                              amount:      withdrawal.amount,
                              currency_id: currency.id)
    end

    before do
      member.get_account(currency).update!(balance: 1000)
      service.adapter.expects(:create_transaction!).returns(transaction)
    end

    it 'sends withdrawal' do
      expect(service.build_withdrawal!(withdrawal)).to eq transaction
    end
  end

  context :spread_between_wallets do

    # Single wallet:
    #   * Deposit fits exactly.
    #   * Deposit doesn't fit.
    # Two wallets:
    #   * Deposit fits to first wallet.
    #   * Deposit fits to second wallet.
    #   * Partial spread between first and second.
    #   * Deposit doesn't fit to both wallets.
    #   * Negative min_collection_amount.
    # Three wallets:
    #   * Partial spread between first and second.
    #   * Partial spread between first and third.
    #   * Partial spread between first, second and third.
    #   * Deposit doesn't fit to all wallets.

    let(:deposit) { Deposit.new(amount: 1.2, currency_id: :fake) }

    context 'Single wallet' do

      context 'single wallet available' do

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 8.8,
            max_balance: 10,
            min_collection_amount: 1,
            plain_settings: { external_wallet_id: 1 }}]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-1',
             status: 'pending',
             amount: deposit.amount,
             currency_id: currency.id,
             options: { external_wallet_id: 1 } }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to single wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'single wallet available + skip_deposit_collection' do

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 8.8,
            max_balance: 10,
            min_collection_amount: deposit.amount,
            skip_deposit_collection: true }]
        end

        let(:expected_spread) do
          [{:amount=>"1.2", :currency_id=>"fake", :status=>"skipped", :to_address=>"destination-wallet-1"}]
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'returns spread with skipped transaction' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
        end
      end

      context 'Single wallet is full' do

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 10,
            max_balance: 10,
            min_collection_amount: 1 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-1',
             status: 'pending',
             amount: deposit.amount,
             currency_id: currency.id }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to last wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end
    end

    context 'Two wallets' do

      context 'Deposit fits to first wallet' do

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 5,
            max_balance: 10,
            min_collection_amount: 1 },
          { address: 'destination-wallet-2',
            balance: 100.0,
            max_balance: 100,
            min_collection_amount: 1 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-1',
             status: 'pending',
             amount: deposit.amount,
             currency_id: currency.id }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to last wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'Deposit fits to second wallet' do

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 10,
            max_balance: 10,
            min_collection_amount: 1 },
          { address: 'destination-wallet-2',
            balance: 95,
            max_balance: 100,
            min_collection_amount: 1 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-2',
             status: 'pending',
             amount: deposit.amount,
             currency_id: currency.id }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to last wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'Partial spread between first and second' do

        let(:deposit) { Deposit.new(amount: 10, currency_id: :fake) }

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 5,
            max_balance: 10,
            min_collection_amount: 1 },
          { address: 'destination-wallet-2',
            balance: 90,
            max_balance: 100,
            min_collection_amount: 1 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-1',
             status: 'pending',
             amount: '5.0',
             currency_id: currency.id },
           { to_address: 'destination-wallet-2',
             status: 'pending',
             amount: '5.0',
             currency_id: currency.id }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to last wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'Two wallets are full' do
        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 10,
            max_balance: 10,
            min_collection_amount: 1 },
          { address: 'destination-wallet-2',
            balance: 100,
            max_balance: 100,
            min_collection_amount: 1 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-2',
             status: 'pending',
             amount: '1.2',
             currency_id: currency.id }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to last wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'different min_collection_amount' do

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 10,
            max_balance: 10,
            min_collection_amount: 1 },
           { address: 'destination-wallet-2',
            balance: 100,
            max_balance: 100,
            min_collection_amount: 2 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-2',
             status: 'pending',
             amount: '1.2',
             currency_id: currency.id }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to single wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'tiny min_collection_amount' do

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
             balance: 10,
             max_balance: 10,
             min_collection_amount: 2 },
           { address: 'destination-wallet-2',
             balance: 100,
             max_balance: 100,
             min_collection_amount: 3 }.as_json].map(&:symbolize_keys)
        end

        let(:expected_spread) { [] }

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to single wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end
    end

    context 'Three wallets' do

      context 'Partial spread between first and second' do

        let(:deposit) { Deposit.new(amount: 10, currency_id: :fake) }

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 5,
            max_balance: 10,
            min_collection_amount: 1 },
          { address: 'destination-wallet-2',
            balance: 95,
            max_balance: 100,
            min_collection_amount: 1 },
          { address: 'destination-wallet-3',
            balance: 1001.0,
            max_balance: 1000,
            min_collection_amount: 1 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-1',
             status: 'pending',
             amount: '5.0',
             currency_id: currency.id },
           { to_address: 'destination-wallet-2',
             status: 'pending',
             amount: '5.0',
             currency_id: currency.id }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to last wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'Partial spread between first and third' do

        let(:deposit) { Deposit.new(amount: 10, currency_id: :fake) }

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 5,
            max_balance: 10,
            min_collection_amount: 1 },
          { address: 'destination-wallet-2',
            balance: 100,
            max_balance: 100,
            min_collection_amount: 1 },
          { address: 'destination-wallet-3',
            balance: 995.0,
            max_balance: 1000,
            min_collection_amount: 1 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-1',
             status: 'pending',
             amount: '5.0',
             currency_id: currency.id },
           { to_address: 'destination-wallet-3',
             status: 'pending',
             amount: '5.0',
             currency_id: currency.id }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to last wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'Three wallets are full' do

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 10.1,
            max_balance: 10,
            min_collection_amount: 1 },
          { address: 'destination-wallet-2',
            balance: 100.0,
            max_balance: 100,
            min_collection_amount: 1 },
          { address: 'destination-wallet-3',
            balance: 1001.0,
            max_balance: 1000,
            min_collection_amount: 1 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-3',
             status: 'pending',
             amount: deposit.amount,
             currency_id: currency.id }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads everything to last wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'Partial spread between first, second and third' do

        let(:deposit) { Deposit.new(amount: 10, currency_id: :fake) }

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 7,
            max_balance: 10,
            min_collection_amount: 1 },
          { address: 'destination-wallet-2',
            balance: 97,
            max_balance: 100,
            min_collection_amount: 1 },
          { address: 'destination-wallet-3',
            balance: 995.0,
            max_balance: 1000,
            min_collection_amount: 1 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-1',
             status: 'pending',
             amount: '3.0',
             currency_id: currency.id },
           { to_address: 'destination-wallet-2',
             status: 'pending',
             amount: '3.0',
             currency_id: currency.id },
           { to_address: 'destination-wallet-3',
             status: 'pending',
             amount: '4.0',
             currency_id: currency.id }.as_json].map(&:symbolize_keys)
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads between wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'Partial spread between first, second and third + skip deposit collection option' do

        let(:deposit) { Deposit.new(amount: 10, currency_id: :fake) }

        let(:destination_wallets) do
          [{ address: 'destination-wallet-1',
            balance: 7,
            max_balance: 10,
            min_collection_amount: 1,
            skip_deposit_collection: true },
          { address: 'destination-wallet-2',
            balance: 97,
            max_balance: 100,
            min_collection_amount: 1 },
          { address: 'destination-wallet-3',
            balance: 995.0,
            max_balance: 1000,
            min_collection_amount: 1 }]
        end

        let(:expected_spread) do
          [{ to_address: 'destination-wallet-1',
             status: 'skipped',
             amount: '3.0',
             currency_id: currency.id },
           { to_address: 'destination-wallet-2',
             status: 'pending',
             amount: '3.0',
             currency_id: currency.id },
           { to_address: 'destination-wallet-3',
             status: 'pending',
             amount: '4.0',
             currency_id: currency.id}]
        end

        subject { service.send(:spread_between_wallets, deposit, destination_wallets) }

        it 'spreads between wallet' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end
    end
  end

  context :spread_deposit do
    before do
      Peatio::Blockchain.registry.expects(:[])
                        .with(:bitcoin)
                        .returns(fake_blockchain_adapter.class)
                        .at_least_once
    end

    let!(:deposit_wallet) { create(:wallet, :fake_deposit) }
    let!(:hot_wallet) { create(:wallet, :fake_hot) }
    let!(:cold_wallet) { create(:wallet, :fake_cold) }

    let(:service) { WalletService.new(deposit_wallet) }

    let(:amount) { 2 }
    let(:deposit) { create(:deposit_btc, amount: amount, blockchain_key: 'fake-testnet', currency: currency) }

    let(:expected_spread) do
      [{ to_address: 'fake-cold',
         status: 'pending',
         amount: '2.0',
         currency_id: currency.id }]
    end

    subject { service.spread_deposit(deposit) }

    context 'hot wallet is full and cold wallet balance is not available' do
      before do
        # Hot wallet balance is full and cold wallet balance is not available.
        Wallet.any_instance.stubs(:current_balance).returns(hot_wallet.max_balance, 'N/A')
      end

      it 'spreads everything to cold wallet' do
        expect(Wallet.active_retired.withdraw.joins(:currencies).where(currencies: { id: deposit.currency_id }).count).to eq 2

        expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
        expect(subject).to all(be_a(Peatio::Transaction))
      end
    end

    context 'hot wallet is full, warm and cold wallet balances are not available' do
      let!(:warm_wallet) { create(:wallet, :fake_warm) }
      before do
        # Hot wallet is full, warm and cold wallet balances are not available.
        Wallet.any_instance.stubs(:current_balance).returns(hot_wallet.max_balance, 'N/A', 'N/A')
      end

      it 'skips warm wallet and spreads everything to cold wallet' do
        expect(Wallet.active_retired.withdraw.joins(:currencies).where(currencies: { id: deposit.currency_id }).count).to eq 3

        expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
        expect(subject).to all(be_a(Peatio::Transaction))
      end
    end

    context 'there is no active wallets' do
      before { Wallet.stubs(:active).returns(Wallet.none) }

      it 'raises an error' do
        expect{ subject }.to raise_error(StandardError)
      end
    end

    context 'currency price recalculation' do
      let(:deposit) { create(:deposit_btc, blockchain_key: 'fake-testnet', amount: amount, currency: currency) }

      context 'collect to hot wallet' do
        let(:expected_spread) do
          [{ to_address: 'fake-hot',
             status: 'pending',
             amount: deposit.amount.to_s,
             currency_id: currency.id }]
        end

        before do
          # Deposit with amount 2 and currency price 42
          hot_wallet.update!(max_balance: 100)
          deposit.currency.update!(price: 42)
          # Hot wallet balance is empty
          Wallet.any_instance.stubs(:current_balance).with(deposit.currency).returns(0)
          Currency.any_instance.unstub(:price)
        end

        it 'skip hot wallet and collect to cold' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'collect to cold wallet' do
        let(:expected_spread) do
          [{ to_address: 'fake-cold',
             status: 'pending',
             amount: deposit.amount.to_s,
             currency_id: currency.id }]
        end

        before do
          # Hot wallet balance is ful.
          deposit.currency.update!(price: 42)
          Wallet.any_instance.stubs(:current_balance).with(deposit.currency).returns(deposit.amount)
          Currency.any_instance.unstub(:price)
        end

        it 'skip hot wallet and collect to cold' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end

      context 'split to hot and cold wallet' do
        let(:expected_spread) do
          [{ to_address: 'fake-hot',
             status: 'pending',
             amount: '1.38095238',
             currency_id: currency.id },
           { to_address: 'fake-cold',
             status: 'pending',
             amount: '0.61904762',
             currency_id: currency.id }]
        end

        before do
          # Deposit with amount 2 and currency price 42
          hot_wallet.update!(max_balance: 100)
          # Hot wallet balance is full and cold wallet balance is not available.
          deposit.currency.update!(price: 42)
          Wallet.any_instance.stubs(:current_balance).with(deposit.currency).returns(deposit.amount / 2)
          Currency.any_instance.unstub(:price)
        end

        it 'skip hot wallet and collect to cold' do
          expect(subject.map(&:as_json).map(&:symbolize_keys)).to contain_exactly(*expected_spread)
          expect(subject).to all(be_a(Peatio::Transaction))
        end
      end
    end
  end

  context :collect_deposit do
    before do
      Peatio::Blockchain.registry.expects(:[])
                        .with(:bitcoin)
                        .returns(fake_blockchain_adapter.class)
                        .at_least_once
    end

    let!(:deposit_wallet) { create(:wallet, :fake_deposit) }
    let!(:hot_wallet) { create(:wallet, :fake_hot) }
    let!(:cold_wallet) { create(:wallet, :fake_cold) }

    let(:amount) { 2 }
    let(:deposit) { create(:deposit_btc, blockchain_key: 'fake-testnet', amount: amount, currency: currency) }

    let(:fake_wallet_adapter) { FakeWallet.new }
    let(:service) { WalletService.new(deposit_wallet) }

    context 'Spread deposit with single entry' do

      let(:spread_deposit) do
        [Peatio::Transaction.new(to_address: 'fake-cold',
                                 amount: '2.0',
                                 currency_id: currency.id)]
      end

      let(:transaction) do
        [Peatio::Transaction.new(hash:        '0xfake',
                                to_address:  cold_wallet.address,
                                amount:      deposit.amount,
                                currency_id: currency.id)]
      end

      subject { service.collect_deposit!(deposit, spread_deposit) }

      before do
        deposit.member.payment_address(service.wallet.id).update(address: deposit.address)
        service.adapter.expects(:create_transaction!).returns(transaction.first)
      end

      it 'creates single transaction' do
        expect(subject).to contain_exactly(*transaction)
        expect(subject).to all(be_a(Peatio::Transaction))
      end
    end

    context 'Spread deposit with two entry' do

      let(:spread_deposit) do
        [Peatio::Transaction.new(to_address: 'fake-hot',
                                amount: '2.0',
                                currency_id: currency.id),
         Peatio::Transaction.new(to_address: 'fake-hot',
                                 amount: '2.0',
                                 currency_id: currency.id)]
      end

      let(:transaction) do
        [{ hash:        '0xfake',
           to_address:  hot_wallet.address,
           amount:      deposit.amount,
           currency_id: currency.id },
         { hash:        '0xfake1',
           to_address:  cold_wallet.address,
           amount:      deposit.amount,
           currency_id: currency.id }].map { |t| Peatio::Transaction.new(t)}
      end

      subject { service.collect_deposit!(deposit, spread_deposit) }

      before do
        deposit.member.payment_address(service.wallet.id).update(address: deposit.address)
        service.adapter.expects(:create_transaction!).with(spread_deposit.first, subtract_fee: true).returns(transaction.first)
        service.adapter.expects(:create_transaction!).with(spread_deposit.second, subtract_fee: true).returns(transaction.second)
      end

      it 'creates two transactions' do
        expect(subject).to contain_exactly(*transaction)
        expect(subject).to all(be_a(Peatio::Transaction))
      end
    end
  end

  context :deposit_collection_fees do
    before do
      Peatio::Blockchain.registry.expects(:[])
                        .with(:bitcoin)
                        .returns(fake_blockchain_adapter.class)
                        .at_least_once
    end

    let!(:fee_wallet) { create(:wallet, :fake_fee) }
    let!(:deposit_wallet) { create(:wallet, :fake_deposit) }

    let(:amount) { 2 }
    let(:deposit) { create(:deposit_btc, blockchain_key: 'fake-testnet', amount: amount, currency: currency) }

    let(:fake_wallet_adapter) { FakeWallet.new }
    let(:service) { WalletService.new(fee_wallet) }

    let(:spread_deposit) do
      [Peatio::Transaction.new(to_address: 'fake-cold',
                               amount: '2.0',
                               currency_id: currency.id,
                               options: { external_wallet_id: 1})]
    end

    let(:transactions) do
      [Peatio::Transaction.new( hash:        '0xfake',
                                to_address:  deposit.address,
                                amount:      '0.01',
                                currency_id: currency.id,
                                options: { gas_limit: 21_000, gas_price: 10_000_000_000 })]
    end

    subject { service.deposit_collection_fees!(deposit, spread_deposit) }

    context 'Adapter collect fees for transaction' do
      before do
        deposit.update!(spread: spread_deposit.map(&:as_json))
        service.adapter.expects(:prepare_deposit_collection!).returns(transactions)
      end

      it 'returns transaction' do
        expect(subject).to contain_exactly(*transactions)
        expect(subject).to all(be_a(Peatio::Transaction))
        deposit.spread.map { |s| s.key?(:options) }
        expect(deposit.spread[0].fetch(:options)).to include :external_wallet_id
      end
    end

    context 'Adapter collect fees for erc20 transaction with parent_id configuration' do
      let!(:eth_blockchain_currency) { create(:blockchain_currency, :eth_network, blockchain_key: 'fake-testnet') }
      let!(:blockchain_currency) { create(:blockchain_currency, :trst_network, blockchain_key: 'fake-testnet') }
      let(:deposit) { create(:deposit_btc, blockchain_key: 'fake-testnet', amount: amount, currency_id: 'trst') }


      subject { service.deposit_collection_fees!(deposit, spread_deposit) }

      before do
        deposit.update!(spread: spread_deposit.map(&:as_json))
        service.adapter.expects(:prepare_deposit_collection!).returns(transactions)
      end

      it 'returns transaction' do
        expect(subject).to contain_exactly(*transactions)
        expect(subject).to all(be_a(Peatio::Transaction))
        deposit.spread.map { |s| s.key?(:options) }
      end
    end

    context "Adapter doesn't perform any actions before collect deposit" do

      it 'retunrs empty array' do
        expect(subject.blank?).to be true
      end
    end
  end

  context :refund do
    before do
      Peatio::Blockchain.registry.expects(:[])
                        .with(:bitcoin)
                        .returns(fake_blockchain_adapter.class)
                        .at_least_once

      create(:blockchain_currency, :btc_network, blockchain_key: 'fake-testnet')
    end

    let!(:deposit_wallet) { create(:wallet, :fake_deposit) }

    let(:amount) { 2 }
    let(:refund_deposit) { create(:deposit_btc, blockchain_key: 'fake-testnet', amount: amount, currency: currency) }

    let(:fake_wallet_adapter) { FakeWallet.new }
    let(:service) { WalletService.new(deposit_wallet) }

    let(:transaction) do
      Peatio::Transaction.new(hash:        '0xfake',
                               to_address:  'user_address',
                               amount:      refund_deposit.amount,
                               currency_id: currency.id)
    end

    let!(:refund) { Refund.create(deposit: refund_deposit, address: 'user_address') }

    subject { service.refund!(refund) }

    before do
      refund_deposit.member.payment_address(service.wallet.id).update(address: refund_deposit.address)
      service.adapter.expects(:create_transaction!).returns(transaction)
    end

    it 'creates single transaction' do
      expect(subject).to eq(transaction)
      expect(subject).to be_a(Peatio::Transaction)
    end
  end
end
