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

        context 'auto_update_fees_enabled false' do
          context 'market doesnt exist' do
            it 'creates blockchain currency with specific fees' do
              blockchain_currency = BlockchainCurrency.create(currency_id: 'eth', blockchain_key: blockchain.key, auto_update_fees_enabled: true, min_deposit_amount: 0.12)
              expect(blockchain_currency.min_deposit_amount).not_to eq 0.12
              expect(blockchain_currency.min_deposit_amount).to eq blockchain.min_deposit_amount/blockchain_currency.currency.price
            end
          end

          context 'market exists' do
            let!(:currency) { create(:currency, :eth, id: 'usdt')}
            let!(:market) { create(:market, symbol: 'ethusdt', type: 'spot', base_currency: 'eth', quote_currency: currency.id,
                                  amount_precision: 4, price_precision: 6, min_price: 0.000001, min_amount: 0.0001)}
            let!(:trade) { create(:trade, :btcusd, market_id: market.symbol, market_type: 'spot', price: '5.0'.to_d, amount: '1.1'.to_d,
                                  total: '5.5'.to_d)}
            let(:min_deposit_amount) { 12 }
            let(:b_currency) { BlockchainCurrency.find_by(currency_id: 'eth', blockchain_key: 'eth-rinkeby')}

            before do
              Blockchain.any_instance.stubs(:min_deposit_amount).returns(12.to_d)
              b_currency.blockchain.update(min_deposit_amount: 12)
            end

            context 'ticker exists' do
              before do
                trade.write_to_influx
              end

              it 'creates blockchain currency with auto update fees' do
                b_currency = BlockchainCurrency.create(currency_id: 'eth', blockchain_key: blockchain.key, auto_update_fees_enabled: true, min_deposit_amount: 2)
                expect(b_currency.min_deposit_amount).not_to eq 2
                expect(b_currency.min_deposit_amount).to eq min_deposit_amount/trade.price
              end
            end

            context 'there is no ticker' do
              before do
                delete_measurments('trades')
              end

              it 'creates blockchain currency with auto update fees' do
                b_currency = BlockchainCurrency.create(currency_id: 'eth', blockchain_key: blockchain.key, auto_update_fees_enabled: true, min_deposit_amount: 2)
                expect(b_currency.min_deposit_amount).not_to eq 2
                expect(b_currency.min_deposit_amount).to eq min_deposit_amount/b_currency.currency.price
              end
            end
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
      let!(:market) { create(:market, symbol: 'ethusdt', type: 'spot', base_currency: 'eth', quote_currency: currency.id,
                            amount_precision: 4, price_precision: 6, min_price: 0.000001, min_amount: 0.0001)}
      let!(:trade) { create(:trade, :btcusd, market_id: market.symbol, market_type: 'spot', price: '5.0'.to_d, amount: '1.1'.to_d,
                            total: '5.5'.to_d)}
      let(:min_deposit_amount) { 12 }
      let(:b_currency) { BlockchainCurrency.find_by(currency_id: 'eth', blockchain_key: 'eth-rinkeby')}

      before do
        Blockchain.any_instance.stubs(:min_deposit_amount).returns(12.to_d)
        b_currency.blockchain.update(min_deposit_amount: 12)
        trade.write_to_influx
      end

      it 'creates blockchain currency with auto update fees' do
        b_currency.update_fees

        expect(b_currency.min_deposit_amount).to eq b_currency.blockchain.min_deposit_amount / trade.price
        expect(b_currency.min_collection_amount).to eq b_currency.blockchain.min_deposit_amount / trade.price
        expect(b_currency.withdraw_fee).to eq b_currency.blockchain.withdraw_fee / trade.price
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
