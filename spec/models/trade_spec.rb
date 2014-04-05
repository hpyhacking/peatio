require 'spec_helper'

describe Trade, "#latest_price" do
  context "no trade" do
    it { expect(Trade.latest_price(:btccny)).to be_d "0.0" }
  end

  context "add one trade" do
    let!(:trade) { create(:trade, currency: :btccny) }
    it { expect(Trade.latest_price(:btccny)).to eq(trade.price) }
  end
end

describe Trade, "#to_notify" do
  let(:order_ask) { create(:order_ask) }
  let(:order_bid) { create(:order_bid) }
  let(:trade) { create(:trade, ask: order_ask, bid: order_bid) }

  subject(:notify) { trade.for_notify('ask') }

  it { expect(notify).not_to be_blank }
  it { expect(notify[:kind]).not_to be_blank }
  it { expect(notify[:at]).not_to be_blank }
  it { expect(notify[:price]).not_to be_blank }
  it { expect(notify[:volume]).not_to be_blank }
end

describe Trade, "#notify" do
  let(:member) { mock('Member') }
  let(:order_ask) { create(:order_ask) }
  let(:order_bid) { create(:order_bid) }

  subject { create(:trade, ask: order_ask, bid: order_bid) }

  before do
    order_ask.stubs(:member).returns(member)
    order_bid.stubs(:member).returns(member)
  end

  it "fire member notificaitons" do
    member.expects(:trigger).at_most(2)
    subject.notify
  end
end
