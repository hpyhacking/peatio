require 'spec_helper'

describe OrderBid do

  subject { create(:order_bid) }

  its(:compute_locked) { should == subject.volume*subject.price }

  context "#estimate_required_funds" do
    let(:price_levels) do
      [ ['1.0'.to_d, '10.0'.to_d],
        ['2.0'.to_d, '20.0'.to_d],
        ['3.0'.to_d, '30.0'.to_d] ]
    end

    before do
      global = Global.new('btccny')
      global.stubs(:asks).returns(price_levels)
      Global.stubs(:[]).returns(global)
    end

    it "should require a little" do
      OrderBid.new(volume: '5'.to_d).estimate_required_funds.should == '5'.to_d
    end

    it "should require more" do
      OrderBid.new(volume: '35'.to_d).estimate_required_funds.should == '65'.to_d
    end

    it "should raise error if the market is not deep enough" do
      expect { OrderBid.new(volume: '100'.to_d).estimate_required_funds }.to raise_error
    end
  end
end
