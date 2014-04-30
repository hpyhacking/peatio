require 'spec_helper'

describe APIv2::Entities::Trade do

  let(:trade) { create(:trade, ask: create(:order_ask), bid: create(:order_bid)) }

  subject { OpenStruct.new APIv2::Entities::Trade.represent(trade, side: 'sell').serializable_hash }

  its(:id)               { should == trade.id }
  its(:price)            { should == trade.price }
  its(:volume)           { should == trade.volume }
  its(:market)           { should == trade.currency }
  its(:created_at)       { should == trade.created_at.iso8601 }
  its(:side)             { should == 'sell' }
  its(:ask)              { should be_nil }
  its(:bid)              { should be_nil }

  context "include order" do
    it "should include associated ask order" do
      hash = APIv2::Entities::Trade.represent(trade, include_order: :ask).serializable_hash
      hash[:ask]['id'].should == trade.ask.id
      hash[:bid].should be_nil
    end

    it "should include associated bid order" do
      hash = APIv2::Entities::Trade.represent(trade, include_order: :bid).serializable_hash
      hash[:ask].should be_nil
      hash[:bid]['id'].should == trade.bid.id
    end
  end

end
