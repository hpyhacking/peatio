# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Entities::Order do
  let(:order) do
    create(
      :order_ask,
      :btcusd,
      price: '12.32'.to_d,
      volume: '3.1418',
      origin_volume: '12.13'
    )
  end

  context 'default exposure' do
    subject { OpenStruct.new API::V2::Entities::Order.represent(order, {}).serializable_hash }

    it do
     expect(subject.id).to eq order.id

     expect(subject.price).to eq order.price
     expect(subject.avg_price).to eq ::Trade::ZERO

     expect(subject.origin_volume).to eq order.origin_volume
     expect(subject.remaining_volume).to eq order.volume
     expect(subject.executed_volume).to eq(order.origin_volume - order.volume)

     expect(subject.state).to eq order.state
     expect(subject.market).to eq order.market_id

     expect(subject.side).to eq 'sell'

     expect(subject.maker_fee).to eq order.maker_fee
     expect(subject.taker_fee).to eq order.taker_fee

     expect(subject.trades).to be_nil
     expect(subject.trades_count).to be_zero

     expect(subject.created_at).to eq order.created_at.iso8601
    end
  end

  context 'full exposure' do
    it 'should expose related trades' do
      create(:trade, :btcusd, maker_order: order, amount: '8.0', price: '12')
      create(:trade, :btcusd, maker_order: order, amount: '0.99', price: '12.56')

      json = API::V2::Entities::Order.represent(order, type: :full).serializable_hash
      expect(json[:trades].size).to eq 2
    end
  end
end
