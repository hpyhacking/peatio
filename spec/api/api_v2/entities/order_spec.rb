require 'spec_helper'

describe APIv2::Entities::Order do

  let(:order)  { create(:order_ask, currency: 'btccny', price: '12.326'.to_d, volume: '3.14', origin_volume: '12.13') }

  context "default exposure" do
    subject { OpenStruct.new APIv2::Entities::Order.represent(order, {}).serializable_hash }

    its(:id)               { should == order.id }
    its(:price)            { should == order.price }
    its(:avg_price)        { should == ::Trade::ZERO }
    its(:volume)           { should == order.origin_volume }
    its(:remaining_volume) { should == order.volume }
    its(:executed_volume)  { should == (order.origin_volume - order.volume)}
    its(:state)            { should == order.state }
    its(:market)           { should == order.market }
    its(:created_at)       { should == order.created_at.iso8601 }
    its(:side)             { should == 'sell' }
    its(:trades)           { should be_nil }
    its(:trades_count)     { should == 0 }
  end

  context "full exposure" do
    it "should expose related trades" do
      create(:trade, ask: order, volume: '8.0', price: '12')
      create(:trade, ask: order, volume: '0.99', price: '12.56')

      json = APIv2::Entities::Order.represent(order, type: :full).serializable_hash 
      json[:trades].should have(2).trades
    end
  end

end
