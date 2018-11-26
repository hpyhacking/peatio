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
  it { expect(notify[:ask_id]).to eq(order_ask.id) }
  it { expect(notify[:bid_id]).to eq(order_bid.id) }

  it 'should use side as kind' do
    trade.side = 'ask'
    expect(trade.for_notify[:kind]).to eq 'ask'
  end
end

describe Trade, '#record_complete_operations!' do
  # Persist orders and trades in database.
  let!(:trade){ create(:trade, :with_deposit_liability, :submitted_orders) }

  let(:ask){ trade.ask }
  let(:bid){ trade.bid }

  let(:ask_currency_outcome){ trade.volume }
  let(:bid_currency_outcome){ trade.funds }

  let(:ask_currency_fee){ trade.volume * bid.fee }
  let(:bid_currency_fee){ trade.funds * ask.fee }

  let(:ask_currency_income){ ask_currency_outcome - ask_currency_fee }
  let(:bid_currency_income){ bid_currency_outcome - bid_currency_fee }

  subject{ trade }

  let(:ask_fee) { 0.002 }
  let(:bid_fee) { 0.001 }
  before do
    trade.market.update(bid_fee: bid_fee, ask_fee: ask_fee)
  end

  it 'creates four liability operations' do
    expect{ subject.record_complete_operations! }.to change{ Operations::Liability.count }.by(4)
  end

  it 'doesn\'t create asset operations' do
    expect{ subject.record_complete_operations! }.to_not change{ Operations::Asset.count }
  end

  it 'debits locked ask liabilities for ask creator' do
    expect{ subject.record_complete_operations! }.to change {
      ask.member.balance_for(currency: ask.currency, kind: :locked)
    }.by(-ask_currency_outcome)
  end

  it 'debits locked bid liabilities for bid creator' do
    expect{ subject.record_complete_operations! }.to change {
      bid.member.balance_for(currency: bid.currency, kind: :locked)
    }.by(-bid_currency_outcome)
  end

  it 'credits main bid liabilities for ask creator' do
    expect{ subject.record_complete_operations! }.to change {
      ask.member.balance_for(currency: bid.currency, kind: :main)
    }.by(bid_currency_income)
  end

  it 'credits main ask liabilities for bid creator' do
    expect{ subject.record_complete_operations! }.to change {
      bid.member.balance_for(currency: ask.currency, kind: :main)
    }.by(ask_currency_income)
  end

  it 'credits ask currency revenues' do
    expect{ subject.record_complete_operations! }.to change {
      Operations::Revenue.balance(currency: ask.currency)
    }.by(ask_currency_fee)
  end

  it 'credits bid currency revenues' do
    expect{ subject.record_complete_operations! }.to change {
      Operations::Revenue.balance(currency: bid.currency)
    }.by(bid_currency_fee)
  end
end
