require 'spec_helper'

describe Matching::PriceLevel do

  subject  { Matching::PriceLevel.new('1.0'.to_d) }
  let(:o1) { Matching.mock_limit_order(type: :ask) }
  let(:o2) { Matching.mock_limit_order(type: :ask) }
  let(:o3) { Matching.mock_limit_order(type: :ask) }

  before do
    subject.add o1
    subject.add o2
    subject.add o3
  end

  it "should remove order" do
    subject.remove o2
    subject.orders.should == [o1, o3]
  end

  it "should find order by id" do
    subject.find(o1.id).should == o1
    subject.find(o2.id).should == o2
  end
end
