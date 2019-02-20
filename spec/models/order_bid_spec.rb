# encoding: UTF-8
# frozen_string_literal: true

describe OrderBid do
  subject { create(:order_bid, :btcusd) }

  it { expect(subject.compute_locked).to eq subject.volume * subject.price }

  let(:market) do
    Market.find(:btcusd).tap { |m| m.update(max_bid_price: 1.0, min_bid_amount: 0.1)}
  end

  context 'compute locked for market order' do
    let(:price_levels) do
      [
        ['100'.to_d, '10.0'.to_d],
        ['101'.to_d, '10.0'.to_d],
        ['102'.to_d, '10.0'.to_d],
        ['200'.to_d, '10.0'.to_d]
      ]
    end

    before do
      global = Global.new('btcusd')
      global.stubs(:asks).returns(price_levels)
      Global.stubs(:[]).returns(global)
    end

    it 'should require a little' do
      expect(OrderBid.new(volume: '5'.to_d, ord_type: 'market').compute_locked).to eq '500'.to_d * OrderBid::LOCKING_BUFFER_FACTOR
    end

    it 'should require more' do
      expect(OrderBid.new(volume: '25'.to_d, ord_type: 'market').compute_locked).to eq '2520'.to_d * OrderBid::LOCKING_BUFFER_FACTOR
    end

    it 'should raise error if the market is not deep enough' do
      expect do
        OrderBid.new(volume: '50'.to_d, ord_type: 'market').compute_locked
      end.to raise_error(Order::InsufficientMarketLiquidity)
    end

    it 'should make sure price is less than max_bid_price' do
      bid = OrderBid.new(market_id: market.id, price: '10.0'.to_d, ord_type: 'limit')
      expect(bid).not_to be_valid
      expect(bid.errors[:price]).to include "must be less than or equal to #{market.max_bid_price}"
    end
    
    it 'should make sure amount is greater than min_bid' do
      bid_amount = OrderBid.new(market_id: market.id, origin_volume: '0.0'.to_d)
      expect(bid_amount).not_to be_valid
      expect(bid_amount.errors[:origin_volume]).to include "must be greater than or equal to #{market.min_bid_amount}"
    end
  end
end
