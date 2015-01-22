require 'spec_helper'

describe Ordering do
  let(:order) { create(:order_bid, volume: '1.23456789', price: '1.23456789') }
  let(:account) { create(:account, balance: 100.to_d, locked: 100.to_d) }

  describe "ordering service can submit order" do
    before do
      order.stubs(:hold_account).returns(account)
      AMQPQueue.expects(:enqueue).with(:matching, anything)
    end

    it "should return true on success" do
      Ordering.new(order).submit.should be_true
    end

    it "should set locked funds on order" do
      Ordering.new(order).submit
      order.locked.should == order.compute_locked
      order.origin_locked.should == order.compute_locked
    end

    it "should compute locked after number precision fixed" do
      Ordering.new(order).submit
      order.reload.locked.should == '1.23'.to_d * '1.2345'.to_d
    end
  end

  describe "ordering service can cancel order" do
    before do
      order.stubs(:hold_account).returns(account)
    end

    it "should soft cancel order" do
      AMQPQueue.expects(:enqueue).with(:matching, action: 'cancel', order: order.to_matching_attributes)
      Ordering.new(order).cancel
    end

    it "should hard cancel order" do
      Ordering.new(order).cancel!
      order.reload.state.should == Order::CANCEL
      account.reload.locked.should == ('100'.to_d - order.locked)
    end
  end
end
