# encoding: UTF-8
# frozen_string_literal: true

describe APIv2::Entities::Trade do
  let(:trade) do
    create :trade, ask: create(:order_ask), bid: create(:order_bid)
  end

  subject { OpenStruct.new APIv2::Entities::Trade.represent(trade, side: 'sell').serializable_hash }

  it { expect(subject.id).to eq trade.id }
  it { expect(subject.order_id).to be_nil }

  it { expect(subject.price).to eq trade.price }
  it { expect(subject.volume).to eq trade.volume }

  it { expect(subject.funds).to eq trade.funds }
  it { expect(subject.market).to eq trade.market_id }

  it { expect(subject.side).to eq 'sell' }

  it { expect(subject.created_at).to eq trade.created_at.iso8601 }
end
