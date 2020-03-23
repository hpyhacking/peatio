# frozen_string_literal: true

describe TickersService, '#ticker' do
  let(:market) { Market.all.sample.id.to_sym }
  let(:service) { TickersService }
  context 'no trades executed' do
    let(:default) do
      {
        amount: '0.0',
        avg_price: '0.0',
        high: '0.0',
        last: '0.0',
        low: '0.0',
        open: '0.0',
        price_change_percent: '+0.00%',
        volume: '0.0'
      }
    end

    it 'returns zero tickers' do
      expect(service[:btcusd].ticker.except(:at)).to eq default
    end
  end

  context 'single trade executed during last 24 hours' do
    after { delete_measurments('trades') }
    let!(:trade) { create(:trade, :btcusd, price: 5, amount: 2) }

    let(:ticker) do
      {
        amount: '2.0',
        avg_price: '5.0',
        high: '5.0',
        last: '5.0',
        low: '5.0',
        open: '5.0',
        price_change_percent: '+0.00%',
        volume: '10.0'
      }
    end

    before do
      trade.write_to_influx
    end

    it 'returns trade price' do
      expect(service[:btcusd].ticker.except(:at)).to eq(ticker)
    end
  end

  context 'multiple trades executed during last 24 hours' do
    after { delete_measurments('trades') }

    let(:trades) do
      [
        create(:trade, :btcusd, price: 12.to_d, amount: 10.to_d),
        create(:trade, :btcusd, price: 11.to_d, amount: 17.to_d),
        create(:trade, :btcusd, price: 10.to_d, amount: 25.to_d),
        create(:trade, :btcusd, price:  9.to_d, amount: 18.to_d),
        create(:trade, :btcusd, price:  8.to_d, amount: 10.to_d)
      ]
    end

    let(:ticker) do
      {
        amount: '80.0',
        avg_price: '9.9875',
        high: '12.0',
        last: '8.0',
        low: '8.0',
        open: '12.0',
        price_change_percent: '-33.33%',
        volume: '799.0'
      }
    end

    before do
      trades.map(&:write_to_influx)
    end

    it 'returns trade price' do
      expect(service[:btcusd].ticker.except(:at)).to eq(ticker)
    end
  end
end
