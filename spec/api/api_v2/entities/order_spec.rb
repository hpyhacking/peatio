require 'spec_helper'

describe APIv2::Entities::Order do

  let(:order) { create(:order_ask, currency: 'btccny', price: '12.326'.to_d, volume: '3.14', origin_volume: '12.13') }

  subject { OpenStruct.new APIv2::Entities::Order.represent(order, {}).serializable_hash }

  its(:id)               { should == order.id }
  its(:price)            { should == order.price }
  its(:volume)           { should == order.origin_volume }
  its(:remaining_volume) { should == order.volume }
  its(:executed_volume)  { should == (order.origin_volume - order.volume)}
  its(:state)            { should == order.state }
  its(:market)           { should == order.market }
  its(:created_at)       { should == order.created_at.iso8601 }
  its(:side)             { should == 'sell' }

end
