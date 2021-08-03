# frozen_string_literal: true

describe BlockchainCurrency do
  context 'validations' do
    let(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: :btc) }

    it 'validates blockchain_key' do
      blockchain_currency.blockchain_key = 'an-nonexistent-key'
      expect(blockchain_currency.valid?).to be_falsey
      expect(blockchain_currency.errors[:blockchain_key].size).to eq(1)

      blockchain_currency.blockchain_key = 'btc-testnet' # an existent key
      expect(blockchain_currency.valid?).to be_truthy
      expect(blockchain_currency.errors[:blockchain_key]).to be_empty
    end

    context 'token' do
      let!(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: :ring) }
      let!(:blockchain_trst_currency) { BlockchainCurrency.find_by(currency_id: :trst) }
      let!(:blockchain_fiat_currency) { BlockchainCurrency.find_by(currency_id: :eur) }

      # coin configuration
      it 'validate parent_id presence' do
        blockchain_currency.parent_id = nil
        expect(blockchain_currency.valid?).to eq true
      end

      # token configuration
      it 'validate parent_id value' do
        blockchain_currency.parent_id = blockchain_fiat_currency.id
        expect(blockchain_currency.valid?).to be_falsey
        expect(blockchain_currency.errors[:parent_id]).to eq ["is not included in the list"]

        blockchain_currency.parent_id = blockchain_trst_currency.id
        expect(blockchain_currency.valid?).to be_falsey
        expect(blockchain_currency.errors[:parent_id]).to eq ["is not included in the list"]
      end
    end

    context 'find_network' do
      context 'current currency network' do
        let(:currency) { Currency.find_by(id: 'eth') }

        it 'should return currency default network' do
          result = BlockchainCurrency.find_network('eth-test', currency.id)
          expect(result).to eq currency.default_network
        end
      end

      context 'current currency network' do
        let(:currency) { Currency.find_by(id: 'eth') }

        it 'should return currency default network' do
          result = BlockchainCurrency.find_network('eth-kovan', currency.id)
          expect(result).not_to eq nil
        end
      end
    end

    context 'link currency with default network' do
      let(:currency) { Currency.find_by(id: 'eth') }

      before do
        currency.update(default_network_id: nil)
      end

      it 'should set currency default network' do
        expect(currency.default_network_id).to eq nil
        expect(currency.default_network).to eq nil
        blockchain_currency = BlockchainCurrency.create(currency_id: 'eth', blockchain_key: 'btc-testnet')
        currency.reload
        expect(currency.default_network).to eq blockchain_currency
      end
    end
  end

  context 'Methods' do
    context 'link_wallets' do
      let(:coin) { 'eth' }
      let(:erc20_coin) { 'trst' }
      let(:blockchain_key) { 'btc-testnet' }
      let!(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: :eth) }

      context 'without parent id' do
        it 'should not create currency wallet' do
          wallet = Wallet.find_by(blockchain_key: blockchain_key)
          expect(wallet).not_to eq nil
          currency = BlockchainCurrency.create(currency_id: coin, blockchain_key: blockchain_key)

          expect(CurrencyWallet.find_by(currency_id: currency.id, wallet_id: wallet.id)).to eq nil
        end
      end

      context 'with parent id' do
        it 'should create currency wallet' do
          wallet = Wallet.find_by(blockchain_key: blockchain_key)
          # create links for parent currency before
          CurrencyWallet.create(currency_id: coin, wallet_id: wallet.id)
          currency = BlockchainCurrency.create(currency_id: erc20_coin, blockchain_key: blockchain_key, parent_id: coin)
          c_w = CurrencyWallet.find_by(currency_id: erc20_coin, wallet_id: wallet.id)

          expect(c_w.present?).to eq true
          expect(c_w.currency_id).to eq erc20_coin
        end
      end
    end
  end

  context 'scopes' do
    let(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: :btc) }

    context 'visible' do
      it 'changes visible scope count' do
        visible = BlockchainCurrency.visible.count
        blockchain_currency.update(status: :disabled)
        expect(BlockchainCurrency.visible.count).to eq(visible - 1)
      end
    end

    context 'deposit_enabled' do
      it 'changes deposit_enabled scope count' do
        deposit_enabled = BlockchainCurrency.deposit_enabled.count
        blockchain_currency.update(deposit_enabled: false)
        expect(BlockchainCurrency.deposit_enabled.count).to eq(deposit_enabled - 1)
      end
    end

    context 'withdrawal_enabled' do
      it 'changes withdrawal_enabled scope count' do
        withdrawal_enabled = BlockchainCurrency.withdrawal_enabled.count
        blockchain_currency.update(withdrawal_enabled: false)
        expect(BlockchainCurrency.withdrawal_enabled.count).to eq(withdrawal_enabled - 1)
      end
    end
  end

  context 'subunits=' do
    let(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: :btc) }

    it 'updates base_factor' do
      expect { blockchain_currency.subunits = 4 }.to change { blockchain_currency.base_factor }.to 10_000
    end
  end

  context 'read only attributes' do
    let(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: :btc) }

    it 'should not update the base factor' do
      blockchain_currency.update_attributes :base_factor => 8
      expect(blockchain_currency.reload.base_factor).to eq(blockchain_currency.base_factor)
    end
  end

  context 'subunits' do
    let(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: :ring) }

    it 'return currency subunits' do
      expect(blockchain_currency.subunits).to eq(6)
    end
  end

  context 'serialization' do
    let!(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: :ring) }

    let(:options) { { "gas_price" => "standard", "erc20_contract_address" => "0x022e292b44b5a146f2e8ee36ff44d3dd863c915c", "gas_limit" => "100000" } }

    it 'should serialize/deserialize options' do
      blockchain_currency.update(options: options)
      expect(blockchain_currency.options).to eq options
    end
  end

  context 'callbacks' do
    context 'update fees' do
      context 'coin' do
        let(:blockchain) { Blockchain.find_by(key: 'btc-testnet') }
        context 'auto_update_fees_enabled false' do
          it 'creates blockchain currency with specific fees' do
            blockchain_currency = BlockchainCurrency.create(currency_id: 'eth', blockchain_key: blockchain.key, auto_update_fees_enabled: false, min_deposit_amount: 0.12)
            expect(blockchain_currency.min_deposit_amount).to eq 0.12
          end
        end

        context 'auto_update_fees_enabled true' do
          let!(:currency) { create(:currency, :eth, id: 'usdt')}
          let(:min_deposit_amount) { 12 }
          let(:b_currency) { BlockchainCurrency.find_by(currency_id: 'eth', blockchain_key: 'eth-rinkeby')}

          before do
            Blockchain.any_instance.stubs(:min_deposit_amount).returns(min_deposit_amount.to_d)
            currency.update(price: 5.5)
            b_currency.blockchain.update(min_deposit_amount: min_deposit_amount)
          end

          it 'creates blockchain currency with auto update fees' do
            b_currency = BlockchainCurrency.create(currency_id: 'eth', blockchain_key: blockchain.key, auto_update_fees_enabled: true, min_deposit_amount: 2)
            expect(b_currency.min_deposit_amount).not_to eq 2
            expect(b_currency.min_deposit_amount).to eq min_deposit_amount/currency.price
          end
        end
      end

      context 'fiat' do
        let(:fiat) { create(:currency, id: 'test', type: 'fiat')}

        context 'auto_update_fees_enabled true' do
          it 'creates blockchain currency with specific fees' do
            blockchain_currency = BlockchainCurrency.create(currency_id: fiat.id, auto_update_fees_enabled: true, min_deposit_amount: 0.12)
            expect(blockchain_currency.min_deposit_amount).to eq 0.12
          end
        end

        context 'auto_update_fees_enabled false' do
          it 'creates blockchain currency with specific fees' do
            blockchain_currency = BlockchainCurrency.create(currency_id: fiat.id, auto_update_fees_enabled: false, min_deposit_amount: 0.12)
            expect(blockchain_currency.min_deposit_amount).to eq 0.12
          end
        end
      end
    end
  end

  context 'methods' do
    context 'update fees' do
      let!(:currency) { create(:currency, :eth, id: 'usdt')}
      let(:min_deposit_amount) { 12 }
      let(:b_currency) { BlockchainCurrency.find_by(currency_id: 'eth', blockchain_key: 'eth-rinkeby')}

      before do
        Blockchain.any_instance.stubs(:min_deposit_amount).returns(min_deposit_amount.to_d)
        currency.update(price: 5.5)
        b_currency.blockchain.update(min_deposit_amount: min_deposit_amount)
      end

      it 'creates blockchain currency with auto update fees' do
        b_currency.update_fees

        expect(b_currency.min_deposit_amount).to eq b_currency.blockchain.min_deposit_amount / currency.price
        expect(b_currency.min_collection_amount).to eq b_currency.blockchain.min_deposit_amount / currency.price
        expect(b_currency.withdraw_fee).to eq b_currency.blockchain.withdraw_fee / currency.price
        expect(b_currency.min_withdraw_amount).to eq b_currency.blockchain.min_withdraw_amount / currency.price
      end
    end
  end

  context 'to_blockchain_api_settings' do
    let(:blockchain_currency) { BlockchainCurrency.find_by(currency_id: 'eth') }

    before do
      Blockchain.any_instance.stubs(:collection_gas_speed).returns('fast')
      Blockchain.any_instance.stubs(:withdrawal_gas_speed).returns('safelow')
    end

    context 'withdrawal gas speed' do
      it 'should return blockchain_api_settings' do
        result = blockchain_currency.to_blockchain_api_settings
        expect(result[:options][:gas_price]).to eq 'safelow'
      end
    end

    context 'collection gas speed' do
      it 'should return blockchain_api_settings' do
        result = blockchain_currency.to_blockchain_api_settings(withdrawal_gas_speed=false)
        expect(result[:options][:gas_price]).to eq 'fast'
      end
    end
  end
end
