require 'spec_helper'

describe Trade, "#latest_price" do
  context "no trade" do
    it { expect(Trade.latest_price(:cnybtc)).to be_d "0.0" }
  end

  context "add one trade" do
    let!(:trade) { create(:trade, currency: :cnybtc) }
    it { expect(Trade.latest_price(:cnybtc)).to eq(trade.price) }
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
