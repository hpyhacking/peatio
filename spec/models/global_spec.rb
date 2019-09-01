# encoding: UTF-8
# frozen_string_literal: true

describe Global, '.avg_h24_price' do

  before { clear_redis }
  after { clear_redis }

  let(:market) { Market.all.sample.id.to_sym }
  let(:global) { Global[market] }
  context 'no trades executed' do
    it 'returns 0' do
      expect(global.avg_h24_price).to eq 0.to_d
    end
  end

  context 'no trades executed for last 24 hours' do
    let!(:trades) { create_list(:trade, 10, market, created_at: 24.hours.ago - 1) }
    it 'returns 0' do
      expect(global.avg_h24_price).to eq 0.to_d
    end
  end

  context 'single trade executed during last 24 hours' do
    let!(:trade) { create(:trade, market, price: 5, amount: 2) }
    it 'returns trade price' do
      expect(global.avg_h24_price).to eq trade.price
    end
  end

  context 'multiple trades executed during last 24 hours' do
    def calculate_vwap(trades)
      total_volume = trades.sum { |t| t.amount }
      trades.sum { |t| t.price * t.amount } / total_volume
    end

    let(:trades_price_volume) do
      [
        { price: 12.to_d, amount: 10.to_d },
        { price: 11.to_d, amount: 17.to_d },
        { price: 10.to_d, amount: 25.to_d },
        { price:  9.to_d, amount: 18.to_d },
        { price:  8.to_d, amount: 10.to_d }
      ]
    end

    let(:vwap) do
      calculate_vwap(trades.to_a)
    end

    let!(:trades) do
      trades_price_volume.each do |h|
        create(:trade, market, price: h[:price], amount: h[:amount])
      end
      Trade.where(market: market)
    end

    it 'returns VWAP' do
      expect(global.avg_h24_price).to eq vwap
    end

    context 'new trade added' do
      let(:old_vwap) { vwap }

      it 'caches VWAP' do
        expect(global.avg_h24_price).to eq old_vwap
        create(:trade, market, price: 15, amount: 20)
        expect(global.avg_h24_price).to eq old_vwap
      end

      it 'updates VWAP after redis clear' do
        expect(global.avg_h24_price).to eq old_vwap
        new_trade = create(:trade, market, price: 15, amount: 20)

        updated_trades = [*trades, new_trade]
        new_vwap = calculate_vwap(updated_trades)
        clear_redis

        expect(old_vwap).to_not eq new_vwap
        expect(global.avg_h24_price).to eq new_vwap
      end
    end
  end
end
