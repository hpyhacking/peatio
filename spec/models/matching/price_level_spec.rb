require 'spec_helper'

describe Matching::PriceLevel do

  subject { Matching::PriceLevel.new('1.0'.to_d) }

  it "should remove order" do
    o1 = Matching.mock_limit_order(type: :ask)
    o2 = Matching.mock_limit_order(type: :ask)
    o3 = Matching.mock_limit_order(type: :ask)
    subject.add o1
    subject.add o2
    subject.add o3
    subject.remove o2
    subject.orders.should == [o1, o3]
  end

end
