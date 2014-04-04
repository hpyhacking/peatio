require 'spec_helper'

describe APIv2::Orders do

  describe "GET /api/v2/orders" do

    let(:member) { create(:member) }

    before do
      create(:order_bid, currency: 'cnybtc', price: '12.326'.to_d, volume: '123.123456789', member: member)
      create(:order_ask, currency: 'cnybtc', price: '12.326'.to_d, volume: '123.123456789', member: member)
    end

    it "should return orders" do
      pending
      get "/api/v2/orders?market=cnybtc&state=wait&limit=20"
      response.should be_success
      JSON.parse(response.body).size.should == 2
    end

  end

end
