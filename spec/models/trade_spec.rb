require 'spec_helper'

describe Trade, ".latest_price" do
  context "no trade" do
    it { expect(Trade.latest_price(:btccny)).to be_d "0.0" }
  end

  context "add one trade" do
    let!(:trade) { create(:trade, currency: :btccny) }
    it { expect(Trade.latest_price(:btccny)).to eq(trade.price) }
  end
end

describe Trade, ".collect_side" do
  let(:member) { create(:member) }
  let(:ask)    { create(:order_ask, member: member) }
  let(:bid)    { create(:order_bid, member: member) }

  let!(:trades) {[
    create(:trade, ask: ask, created_at: 2.days.ago),
    create(:trade, bid: bid, created_at: 1.day.ago)
  ]}

  it "should add side attribute on trades" do
    results = Trade.for_member(ask.currency, member)
    results.should have(2).trades
    results.find {|t| t.id == trades.first.id }.side.should == 'ask'
    results.find {|t| t.id == trades.last.id  }.side.should == 'bid'
  end

  it "should sort trades in reverse creation order" do
    Trade.for_member(ask.currency, member, order: 'id desc').first.should == trades.last
  end

  it "should return 1 trade" do
    results = Trade.for_member(ask.currency, member, limit: 1)
    results.should have(1).trade
  end

  it "should return trades from specified time" do
    results = Trade.for_member(ask.currency, member, time_to: 30.hours.ago)
    results.should have(1).trade
    results.first.should == trades.first
  end
end

describe Trade, "#for_notify" do
  let(:order_ask) { create(:order_ask) }
  let(:order_bid) { create(:order_bid) }
  let(:trade) { create(:trade, ask: order_ask, bid: order_bid) }

  subject(:notify) { trade.for_notify('ask') }

  it { expect(notify).not_to be_blank }
  it { expect(notify[:kind]).not_to be_blank }
  it { expect(notify[:at]).not_to be_blank }
  it { expect(notify[:price]).not_to be_blank }
  it { expect(notify[:volume]).not_to be_blank }

  it "should use side as kind" do
    trade.side = 'ask'
    trade.for_notify[:kind].should == 'ask'
  end

end
