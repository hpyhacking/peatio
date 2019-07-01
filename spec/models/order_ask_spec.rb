# encoding: UTF-8
# frozen_string_literal: true

describe OrderAsk do
  subject { create(:order_ask, :btcusd) }

  it { expect(subject.compute_locked).to eq subject.volume }

  let(:market) do
    Market.find(:btcusd).tap { |m| m.update(min_price: 0.1, min_amount: 0.1, max_price: 0.11) }
  end

  context 'compute locked for market order' do
    let(:price_levels) do
      [
        ['202'.to_d, '10.0'.to_d],
        ['201'.to_d, '10.0'.to_d],
        ['200'.to_d, '10.0'.to_d],
        ['100'.to_d, '10.0'.to_d]
      ]
    end

    before do
      global = Global.new('btcusd')
      global.stubs(:asks).returns(price_levels)
      Global.stubs(:[]).returns(global)
    end

    it 'should require a little' do
      bid = OrderBid.new(volume: '5'.to_d, ord_type: 'market').compute_locked
      expect(bid).to eq('1010'.to_d * OrderBid::LOCKING_BUFFER_FACTOR)
    end

    it 'should make sure price is greater than min_ask_price' do
      ask = OrderAsk.new(market_id: market.id, price: '0.0'.to_d, ord_type: 'limit')
      expect(ask).not_to be_valid
      expect(ask.errors[:price]).to include "must be greater than or equal to #{market.min_price}"
    end

    it 'should make sure amount is greater than zero' do
      ask_amount = OrderAsk.new(market_id: market.id, origin_volume: '0.0'.to_d)
      expect(ask_amount).not_to be_valid

      expect(ask_amount.errors[:origin_volume]).to include "must be greater than 0"
    end

    it 'should make sure amount is greater than min_amount' do
      ask_amount = OrderAsk.new(market_id: market.id, origin_volume: '0.05'.to_d)
      expect(ask_amount).not_to be_valid

      expect(ask_amount.errors[:origin_volume]).to include "must be greater than or equal to #{market.min_amount}"
    end
  end
end
