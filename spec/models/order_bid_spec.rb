# == Schema Information
#
# Table name: orders
#
#  id             :integer          not null, primary key
#  bid            :integer
#  ask            :integer
#  currency       :integer
#  price          :decimal(32, 16)
#  volume         :decimal(32, 16)
#  origin_volume  :decimal(32, 16)
#  state          :integer
#  done_at        :datetime
#  type           :string(8)
#  member_id      :integer
#  created_at     :datetime
#  updated_at     :datetime
#  sn             :string(255)
#  source         :string(255)      not null
#  ord_type       :string(10)
#  locked         :decimal(32, 16)
#  origin_locked  :decimal(32, 16)
#  funds_received :decimal(32, 16)  default(0.0)
#

require 'spec_helper'

describe OrderBid do

  subject { create(:order_bid) }

  its(:compute_locked) { should == subject.volume*subject.price }

  context "compute locked for market order" do
    let(:price_levels) do
      [ ['100'.to_d, '10.0'.to_d],
        ['101'.to_d, '10.0'.to_d],
        ['102'.to_d, '10.0'.to_d],
        ['200'.to_d, '10.0'.to_d] ]
    end

    before do
      global = Global.new('btccny')
      global.stubs(:asks).returns(price_levels)
      Global.stubs(:[]).returns(global)
    end

    it "should require a little" do
      OrderBid.new(volume: '5'.to_d, ord_type: 'market').compute_locked.should == '500'.to_d.mult_and_round(OrderBid::LOCKING_BUFFER_FACTOR)
    end

    it "should require more" do
      OrderBid.new(volume: '25'.to_d, ord_type: 'market').compute_locked.should == '2520'.to_d.mult_and_round(OrderBid::LOCKING_BUFFER_FACTOR)
    end

    it "should raise error if the market is not deep enough" do
      expect { OrderBid.new(volume: '50'.to_d, ord_type: 'market').compute_locked }.to raise_error
    end

    it "should raise error if volume is too large" do
      expect { OrderBid.new(volume: '30'.to_d, ord_type: 'market').compute_locked }.not_to raise_error
      expect { OrderBid.new(volume: '31'.to_d, ord_type: 'market').compute_locked }.to raise_error
    end
  end

end
