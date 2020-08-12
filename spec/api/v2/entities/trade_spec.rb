# encoding: UTF-8
# frozen_string_literal: true

describe API::V2::Entities::Trade do
  let(:trade) do
    create :trade, :btcusd, maker_order: create(:order_ask, :btcusd), taker_order: create(:order_bid, :btcusd)
  end

  subject { OpenStruct.new API::V2::Entities::Trade.represent(trade, side: 'sell').serializable_hash }

  it do
    expect(subject.id).to eq trade.id
    expect(subject.order_id).to be_nil
    expect(subject.price).to eq trade.price
    expect(subject.amount).to eq trade.amount
    expect(subject.total).to eq trade.total
    expect(subject.market).to eq trade.market_id
    expect(subject.side).to eq 'sell'
    expect(subject.created_at).to eq trade.created_at.iso8601
  end

  context 'sell order maker' do
    it { expect(subject.taker_type).to eq 'buy' }
  end

  context 'buy order maker' do
    let(:trade) do
      create :trade, :btcusd, maker_order: create(:order_bid, :btcusd), taker_order: create(:order_ask, :btcusd)
    end

    it { expect(subject.taker_type).to eq 'sell' }
  end

  context 'empty side' do
    subject { OpenStruct.new API::V2::Entities::Trade.represent(trade).serializable_hash }
    it { expect(subject.respond_to?(:side)).to be_falsey }
  end
end
