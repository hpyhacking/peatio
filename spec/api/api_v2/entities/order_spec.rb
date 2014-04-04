require 'spec_helper'

describe APIv2::Entities::Order do

  let(:order) { create(:order_ask, currency: 'cnybtc', price: '12.326'.to_d, volume: '123.123456789') }

  subject { OpenStruct.new APIv2::Entities::Order.represent(order, {}).serializable_hash }

  its(:id)         { should == order.id }
  its(:price)      { should == order.price }
  its(:volume)     { should == order.origin_volume }
  its(:state)      { should == order.state }
  its(:market)     { should == order.market }
  its(:created_at) { should == order.created_at.iso8601 }
  its(:side)       { should == 'Sell' }

end
