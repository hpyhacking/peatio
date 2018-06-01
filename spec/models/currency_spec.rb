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
  end

  it 'disables markets when currency is set to disabled' do
    currency = Currency.find(:usd)
    expect(Market.find(:btcusd).enabled?).to be_truthy
    expect(Market.find(:dashbtc).enabled?).to be_truthy

    currency.update!(enabled: false)
    expect(Market.find(:btcusd).enabled?).to be_falsey
    expect(Market.find(:dashbtc).enabled?).to be_truthy

    currency.update!(enabled: true)
    expect(Market.find(:btcusd).enabled?).to be_falsey
    expect(Market.find(:dashbtc).enabled?).to be_truthy
  end
end
