require 'spec_helper'

describe Global do
  let(:global) { Global['btccny'] }

  describe Global, '#ticker' do
    it "expect store to redis" do
      expect(global.ticker).to_not be_empty
    end
  end

  describe Global, '#asks' do
    it "expect store asks to redis" do
      create(:order_ask)
      expect(global.asks).to_not be_empty
    end
  end

  describe Global, '#bids' do
    before { create(:order_bid) }

    it "not empty" do
      expect(global.bids).not_to be_empty
    end
  end

  describe Global, '#trades' do
    it "expect store to redis" do
      create(:trade, currency: 'btccny')
      expect(global.trades).to_not be_empty
    end
  end
end

