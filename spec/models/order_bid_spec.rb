# encoding: UTF-8
# frozen_string_literal: true

describe OrderBid do
  subject { create(:order_bid, :btcusd) }

  it { expect(subject.compute_locked).to eq subject.volume * subject.price }

  let(:market) do
    Market.find(:btcusd).tap { |m| m.update(max_price: 1.0, min_amount: 0.1)}
  end

  context 'compute locked for market order' do
    let!(:ask_orders) do
      create(:order_ask, :btcusd, price: '200', volume: '10.0', state: :wait)
      create(:order_ask, :btcusd, price: '102', volume: '10.0', state: :wait)
      create(:order_ask, :btcusd, price: '101', volume: '10.0', state: :wait)
      create(:order_ask, :btcusd, price: '100', volume: '10.0', state: :wait)
    end

    let!(:bid_orders) do
      create(:order_bid, :btcusd, price: '200', volume: '10.0', state: :wait)
      create(:order_bid, :btcusd, price: '102', volume: '10.0', state: :wait)
      create(:order_bid, :btcusd, price: '101', volume: '10.0', state: :wait)
      create(:order_bid, :btcusd, price: '100', volume: '10.0', state: :wait)
    end

    it 'should require a volume' do
      expect(OrderAsk.new(market_id: :btcusd, volume: '5'.to_d, ord_type: 'market').compute_locked).to eq '5'.to_d
    end

    it 'should require a volume' do
      expect(OrderAsk.new(market_id: :btcusd, volume: '25'.to_d, ord_type: 'market').compute_locked).to eq '25'.to_d
    end

    it 'should raise error if the market is not deep enough' do
      expect do
        OrderBid.new(market_id: :btcusd, volume: '50'.to_d, ord_type: 'market').compute_locked
      end.to raise_error(Order::InsufficientMarketLiquidity)
    end

    it 'should make sure price is less than max_price' do
      bid = OrderBid.new(market_id: market.id, price: '10.0'.to_d, ord_type: 'limit')
      expect(bid).not_to be_valid
      expect(bid.errors[:price]).to include "must be less than or equal to #{market.max_price}"
    end

    it 'should make sure amount is greater than min_bid' do
      bid_amount = OrderBid.new(market_id: market.id, origin_volume: '0.0'.to_d)
      expect(bid_amount).not_to be_valid
      expect(bid_amount.errors[:origin_volume]).to include "must be greater than or equal to #{market.min_amount}"
    end
  end
end
