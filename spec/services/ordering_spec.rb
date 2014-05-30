require 'spec_helper'

describe Ordering do
  let(:order) { create(:order_ask) }
  let(:account) { create(:account, balance: 100.to_d, locked: 100.to_d) }

  describe "ordering service can submit order" do
    before do
      order.stubs(:hold_account).returns(account)
      AMQPQueue.expects(:enqueue).with(:matching, action: 'submit', order: order.to_matching_attributes)
    end

    it "should return true on success" do
      Ordering.new(order).submit.should be_true
    end

    it "should set locked funds on order" do
      Ordering.new(order).submit
      order.locked.should == order.compute_locked
      order.origin_locked.should == order.compute_locked
    end
  end

  describe "ordering service can cancel order" do
    before do
      order.stubs(:hold_account).returns(account)
      AMQPQueue.expects(:enqueue).with(:matching, action: 'cancel', order: order.to_matching_attributes)
    end

    it { expect(Ordering.new(order).cancel).to be_true }
  end
end
