
describe Trade, "#latest_price" do
  context "add one trade" do
    let!(:trade) { create(:trade, price: "10.00") }
    it { expect(Trade.latest_price(:cnybtc)).to be_d "10.00" }
  end
  it { expect(Trade.latest_price(:cnybtc)).to be_d "0.0" }
end
