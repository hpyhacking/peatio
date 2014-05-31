require 'spec_helper'

describe Matching::MarketOrder do

  context "initialize" do
    it "should not allow price attribute" do
      expect { Matching.mock_market_order(type: :ask, price: '1.0'.to_d) }.to raise_error
    end

    it "should only accept positive sum limit" do
      expect { Matching.mock_market_order(type: :bid, locked: '0.0'.to_d) }.to raise_error
    end
  end

  context "#fill" do
    subject { Matching.mock_market_order(type: :bid, locked: '10.0'.to_d, volume: '2.0'.to_d) }

    it "should raise not enough volume error" do
      expect { subject.fill('1.0'.to_d, '3.0'.to_d, '3.0'.to_d) }.to raise_error(Matching::NotEnoughVolume)
    end

    it "should raise sum limit reached error" do
      expect { subject.fill('11.0'.to_d, '1.0'.to_d, '11.0'.to_d) }.to raise_error(Matching::ExceedSumLimit)
    end

    it "should also decrease volume and sum limit" do
      subject.fill '6.0'.to_d, '1.0'.to_d, '6.0'.to_d
      subject.volume.should == '1.0'.to_d
      subject.locked.should == '4.0'.to_d
    end
  end

end
