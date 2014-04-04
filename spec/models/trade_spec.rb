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
