# encoding: UTF-8
# frozen_string_literal: true

describe Matching::LimitOrder do
  context 'initialize' do
    it 'should throw invalid order error for empty attributes' do
      expect do
        Matching::LimitOrder.new(type: '', price: '', volume: '')
      end.to raise_error(Matching::InvalidOrderError)
    end

    it 'should initialize market' do
      expect(Matching.mock_limit_order(type: :bid).market).to eq 'btcusd'
    end
  end

  context 'crossed?' do
    it 'should cross at lower or equal price for bid order' do
      order = Matching.mock_limit_order(type: :bid, price: '10.0'.to_d)
      expect(order.crossed?('9.0'.to_d)).to be true
      expect(order.crossed?('10.0'.to_d)).to be true
      expect(order.crossed?('11.0'.to_d)).to be false
    end

    it 'should cross at higher or equal price for ask order' do
      order = Matching.mock_limit_order(type: :ask, price: '10.0'.to_d)
      expect(order.crossed?('9.0'.to_d)).to be false
      expect(order.crossed?('10.0'.to_d)).to be true
      expect(order.crossed?('11.0'.to_d)).to be true
    end
  end
end
