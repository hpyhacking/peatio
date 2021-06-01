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
end
