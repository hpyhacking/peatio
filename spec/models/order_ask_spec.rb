# == Schema Information
#
# Table name: orders
#
#  id            :integer          not null, primary key
#  bid           :integer
#  ask           :integer
#  currency      :integer
#  price         :decimal(32, 16)
#  volume        :decimal(32, 16)
#  origin_volume :decimal(32, 16)
#  state         :integer
#  done_at       :datetime
#  type          :string(8)
#  member_id     :integer
#  created_at    :datetime
#  updated_at    :datetime
#  sn            :string(255)
#  source        :string(255)      not null
#  ord_type      :string(10)
#  locked        :decimal(32, 16)
#  origin_locked :decimal(32, 16)
#

require 'spec_helper'

describe OrderAsk do

  subject { create(:order_ask) }

  its(:compute_locked) { should == subject.volume }

  context "compute locked for market order" do
    let(:price_levels) do
      [ ['202'.to_d, '10.0'.to_d],
        ['201'.to_d, '10.0'.to_d],
        ['200'.to_d, '10.0'.to_d],
        ['100'.to_d, '10.0'.to_d] ]
    end

    before do
      global = Global.new('btccny')
      global.stubs(:asks).returns(price_levels)
      Global.stubs(:[]).returns(global)
    end

    it "should require a little" do
      OrderBid.new(volume: '5'.to_d, ord_type: 'market').compute_locked.should == '1010'.to_d.mult_and_round(OrderBid::LOCKING_BUFFER_FACTOR)
    end

    it "should raise error if volume is too large" do
      expect { OrderBid.new(volume: '30'.to_d, ord_type: 'market').compute_locked }.not_to raise_error
      expect { OrderBid.new(volume: '31'.to_d, ord_type: 'market').compute_locked }.to raise_error
    end
  end

end
