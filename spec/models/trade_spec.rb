# encoding: UTF-8
# frozen_string_literal: true

describe Trade, '.latest_price' do
  context 'no trade' do
    it { expect(Trade.latest_price(:btcusd)).to be_d '0.0' }
  end

  context 'add one trade' do
    let!(:trade) { create(:trade, market_id: :btcusd) }
    it { expect(Trade.latest_price(:btcusd)).to eq(trade.price) }
  end
end

describe Trade, '.collect_side' do
  let(:member) { create(:member, :level_3) }
  let(:ask)    { create(:order_ask, member: member) }
  let(:bid)    { create(:order_bid, member: member) }

  let!(:trades) do
    [
      create(:trade, ask: ask, created_at: 2.days.ago),
      create(:trade, bid: bid, created_at: 1.day.ago)
    ]
  end

  it 'should add side attribute on trades' do
    results = Trade.for_member(ask.market_id, member)
    expect(results.size).to eq 2
    expect(results.find { |t| t.id == trades.first.id }.side).to eq 'ask'
    expect(results.find { |t| t.id == trades.last.id  }.side).to eq 'bid'
  end

  it 'should sort trades in reverse creation order' do
    expect(Trade.for_member(ask.market_id, member, order: 'id desc').first).to eq trades.last
  end

  it 'should return 1 trade' do
    results = Trade.for_member(ask.market_id, member, limit: 1)
    expect(results.size).to eq 1
  end

  it 'should return trades from specified time' do
    results = Trade.for_member(ask.market_id, member, time_to: 30.hours.ago)
    expect(results.size).to eq 1
    expect(results.first).to eq trades.first
  end
end

describe Trade, '#for_notify' do
  let(:order_ask) { create(:order_ask) }
  let(:order_bid) { create(:order_bid) }
  let(:trade) { create(:trade, ask: order_ask, bid: order_bid) }

  subject(:notify) { trade.for_notify('ask') }

  it { expect(notify).not_to be_blank }
  it { expect(notify[:kind]).not_to be_blank }
  it { expect(notify[:at]).not_to be_blank }
  it { expect(notify[:price]).not_to be_blank }
  it { expect(notify[:volume]).not_to be_blank }

  it 'should use side as kind' do
    trade.side = 'ask'
    expect(trade.for_notify[:kind]).to eq 'ask'
  end
end
