# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Entities::Trade do
  let(:trade) do
    create :trade, :btcusd, ask: create(:order_ask, :btcusd), bid: create(:order_bid, :btcusd)
  end

  subject { OpenStruct.new API::V2::Entities::Trade.represent(trade, side: 'sell').serializable_hash }

  it { expect(subject.id).to eq trade.id }
  it { expect(subject.order_id).to be_nil }

  it { expect(subject.price).to eq trade.price }
  it { expect(subject.volume).to eq trade.volume }

  it { expect(subject.funds).to eq trade.funds }
  it { expect(subject.market).to eq trade.market_id }

  it { expect(subject.side).to eq 'sell' }

  it { expect(subject.created_at).to eq trade.created_at.iso8601 }

  context 'sell order maker' do
    it { expect(subject.taker_type).to eq :buy }
  end

  context 'buy order maker' do
    let(:trade) do
      create :trade, :btcusd, bid: create(:order_bid, :btcusd), ask: create(:order_ask, :btcusd)
    end

    it { expect(subject.taker_type).to eq :sell }
  end

  context 'empty side' do
    subject { OpenStruct.new API::V2::Entities::Trade.represent(trade).serializable_hash }
    it { expect(subject.respond_to?(:side)).to be_falsey }
  end
end
