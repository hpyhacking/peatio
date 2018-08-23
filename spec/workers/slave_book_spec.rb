# encoding: UTF-8
# frozen_string_literal: true

describe Worker::SlaveBook do
  subject { Worker::SlaveBook.new(false) }

  let(:market)   { Market.find(:btcusd) }
  let(:low_ask)  { Matching.mock_limit_order(type: 'ask', price: '10.0'.to_d) }
  let(:high_ask) { Matching.mock_limit_order(type: 'ask', price: '12.0'.to_d) }
  let(:low_bid)  { Matching.mock_limit_order(type: 'bid', price: '6.0'.to_d) }
  let(:high_bid) { Matching.mock_limit_order(type: 'bid', price: '8.0'.to_d) }

  context '#get_depth' do
    before do
      subject.process({ action: 'add', order: low_ask.attributes }, {}, {})
      subject.process({ action: 'add', order: high_ask.attributes }, {}, {})
      subject.process({ action: 'add', order: low_bid.attributes }, {}, {})
      subject.process({ action: 'add', order: high_bid.attributes }, {}, {})
    end

    it 'should return lowest asks' do
      expect(subject.get_depth(market, :ask)).to eq [
        ['10.0'.to_d, low_ask.volume],
        ['12.0'.to_d, high_ask.volume]
      ]
    end

    it 'should return highest bids' do
      expect(subject.get_depth(market, :bid)).to eq [
        ['8.0'.to_d, high_bid.volume],
        ['6.0'.to_d, low_bid.volume]
      ]
    end

    it 'should updated volume' do
      attrs = low_ask.attributes.merge(volume: '0.01'.to_d)
      subject.process({ action: 'update', order: attrs }, {}, {})
      expect(subject.get_depth(market, :ask)).to eq [
        ['10.0'.to_d, '0.01'.to_d],
        ['12.0'.to_d, high_ask.volume]
      ]
    end
  end

  context '#process' do
    it 'should create new orderbook manager' do
      subject.process({ action: 'add', order: low_ask.attributes }, {}, {})
      subject.process({ action: 'new', market: market.id, side: 'ask' }, {}, {})
      expect(subject.get_depth(market, :ask)).to be_empty
    end

    it 'should remove an empty order' do
      subject.process({ action: 'add', order: low_ask.attributes }, {}, {})
      expect(subject.get_depth(market, :ask)).to_not be_empty

      # after matching, order volume could be ZERO
      attrs = low_ask.attributes.merge(volume: '0.0'.to_d)
      subject.process({ action: 'remove', order: attrs }, {}, {})

      expect(subject.get_depth(market, :ask)).to be_empty
    end
  end
end
