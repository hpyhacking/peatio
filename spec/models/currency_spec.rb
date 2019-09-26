# encoding: UTF-8
# frozen_string_literal: true

describe Currency do
  context 'fiat' do
    let(:currency) { Currency.find(:usd) }
    it 'allows to change deposit fee' do
      currency.update!(deposit_fee: 0.25)
      expect(currency.deposit_fee).to eq 0.25
    end
  end

  context 'coin' do
    let(:currency) { Currency.find(:btc) }
    it 'doesn\'t allow to change deposit fee' do
      currency.update!(deposit_fee: 0.25)
      expect(currency.deposit_fee).to eq 0
    end

    it 'validates blockchain_key' do
      currency.blockchain_key = 'an-nonexistent-key'
      expect(currency.valid?).to be_falsey
      expect(currency.errors[:blockchain_key].size).to eq(1)

      currency.blockchain_key = 'btc-testnet' # an existent key
      expect(currency.valid?).to be_truthy
      expect(currency.errors[:blockchain_key]).to be_empty
    end
  end

  context 'scopes' do
    let(:currency) { Currency.find(:btc) }

    context 'visible' do
      it 'changes visible scope count' do
        visible = Currency.visible.count
        currency.update(visible: false)
        expect(Currency.visible.count).to eq(visible - 1)
      end
    end

    context 'deposit_enabled' do
      it 'changes deposit_enabled scope count' do
        deposit_enabled = Currency.deposit_enabled.count
        currency.update(deposit_enabled: false)
        expect(Currency.deposit_enabled.count).to eq(deposit_enabled - 1)
      end
    end

    context 'withdrawal_enabled' do
      it 'changes withdrawal_enabled scope count' do
        withdrawal_enabled = Currency.withdrawal_enabled.count
        currency.update(withdrawal_enabled: false)
        expect(Currency.withdrawal_enabled.count).to eq(withdrawal_enabled - 1)
      end
    end
  end

  it 'disables markets when currency is set to disabled' do
    currency = Currency.find(:eth)
    expect(Market.find(:btcusd).state.enabled?).to be_truthy
    expect(Market.find(:btceth).state.enabled?).to be_truthy

    currency.update!(visible: false)
    expect(Market.find(:btcusd).state.enabled?).to be_truthy
    expect(Market.find(:btceth).state.enabled?).to be_falsey

    currency.update!(visible: true)
    expect(Market.find(:btcusd).state.enabled?).to be_truthy
    expect(Market.find(:btceth).state.enabled?).to be_falsey
  end

  it 'allows to disable all dependent markets' do
    Market.where.not(base_unit: 'btc').update_all(state: :disabled)
    currency = Currency.find(:btc)
    currency.update(visible: false)
    expect(currency.valid?).to be_truthy
    expect(currency.errors[:currency].size).to eq(0)
  end

  context 'subunits=' do
    let!(:currency) { Currency.find(:btc) }

    it 'updates base_factor' do
      expect { currency.subunits = 4 }.to change { currency.base_factor }.to 10_000
    end
  end

  context 'read only attributes' do
    let!(:fake_currency) { create(:currency, :btc, id: 'fake') }

    it 'should not update the base factor' do
      fake_currency.update_attributes :base_factor => 8
      expect(fake_currency.reload.base_factor).to eq(fake_currency.base_factor)
    end

    it 'should not update the type' do
      fake_currency.update_attributes :type => 'fiat'
      expect(fake_currency.reload.type).to eq(fake_currency.type)
    end
  end

  context 'subunits' do
    let!(:fake_currency) { create(:currency, :btc, id: 'fake', base_factor: 100) }

    it 'return currency subunits' do
      expect(fake_currency.subunits).to eq(2)
    end
  end
end
