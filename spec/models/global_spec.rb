require 'spec_helper'

describe Global do
  let(:redis) { Redis.new }
  let(:global) { Global['cnybtc'] }

  describe Global, '#update_ticker' do
    it "expect store to redis" do
      expect(global.ticker).to_not be_empty
    end
  end

  describe Global, '#update_asks' do
    it "expect store asks to redis" do
      create(:order_ask)
      expect(global.asks).to_not be_empty
    end
  end

  describe Global, '#update_trades' do
    it "expect store to redis" do
      create(:trade, currency: 'cnybtc')
      expect(global.trades).to_not be_empty
    end
  end
end

