require 'spec_helper'

describe DepositChannel do

  context "#sort" do
    let(:dc1) { DepositChannel.new }
    let(:dc2) { DepositChannel.new }

    it "sort DepositChannel" do
      dc1.stubs(:sort_order).returns 1
      dc2.stubs(:sort_order).returns 2
      expect([dc2, dc1].sort.first.sort_order).to eq(1)
    end
  end

end
