# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Entities::Order do
  let(:order) do
    create(
      :order_ask,
      market_id: 'btcusd',
      price: '12.326'.to_d,
      volume: '3.14',
      origin_volume: '12.13'
    )
  end

  context 'default exposure' do
    subject { OpenStruct.new APIv2::Entities::Order.represent(order, {}).serializable_hash }

    it { expect(subject.id).to eq order.id }

    it { expect(subject.price).to eq order.price }
    it { expect(subject.avg_price).to eq ::Trade::ZERO }

    it { expect(subject.volume).to eq order.origin_volume }
    it { expect(subject.remaining_volume).to eq order.volume }
    it { expect(subject.executed_volume).to eq(order.origin_volume - order.volume) }

    it { expect(subject.state).to eq order.state }
    it { expect(subject.market).to eq order.market_id }

    it { expect(subject.side).to eq 'sell' }

    it { expect(subject.trades).to be_nil }
    it { expect(subject.trades_count).to be_zero }

    it { expect(subject.created_at).to eq order.created_at.iso8601 }
  end

  context 'full exposure' do
    it 'should expose related trades' do
      create(:trade, ask: order, volume: '8.0', price: '12')
      create(:trade, ask: order, volume: '0.99', price: '12.56')

      json = APIv2::Entities::Order.represent(order, type: :full).serializable_hash
      expect(json[:trades].size).to eq 2
    end
  end
end
