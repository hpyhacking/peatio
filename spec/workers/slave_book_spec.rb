# encoding: UTF-8
# frozen_string_literal: true

describe Worker::SlaveBook do
  subject { Worker::SlaveBook.new(false) }

  let(:market) { Market.find(:btcusd) }
 
  context '#get_depth' do

    let!(:low_ask)  { create(:order_ask, market: market, price: '10.0') }
    let!(:high_ask) { create(:order_ask, market: market, price: '12.0') }
    let!(:low_bid)  { create(:order_bid, market: market, price: '6.0') }
    let!(:high_bid) { create(:order_bid, market: market, price: '8.0') }

    it 'returns lowest asks' do
      expect(subject.get_depth(market, :ask)).to eq [
        ['10.0'.to_d, low_ask.volume],
        ['12.0'.to_d, high_ask.volume]
      ]
    end

    it 'returns highest bids' do
      expect(subject.get_depth(market, :bid)).to eq [
        ['8.0'.to_d, high_bid.volume],
        ['6.0'.to_d, low_bid.volume]
      ]
    end

    it 'updates volume' do
      attrs = low_ask.update!(volume: '0.01'.to_d)
      subject.process({ action: 'update', order: attrs }, {}, {})
      expect(subject.get_depth(market, :ask)).to eq [
        ['10.0'.to_d, '0.01'.to_d],
        ['12.0'.to_d, high_ask.volume]
      ]
    end
  end
end
