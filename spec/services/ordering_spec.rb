require 'spec_helper'

describe Ordering do
  let(:order) { create(:order_ask) }
  let(:account) { create(:account, balance: 100.to_d, locked: 100.to_d) }

  describe "ordering service can submit order" do
    before do
      order.stubs(:hold_account).returns(account)
      AMQPQueue.expects(:enqueue).with(:order_dispatcher, order.to_matching_attributes)
    end

    it {expect(Ordering.new(order).submit).to be_true }
  end

  describe "ordering service can cancel order" do
    before do
      order.stubs(:hold_account).returns(account)
      AMQPQueue.expects(:enqueue).with(:matching, action: 'cancel', order: order.to_matching_attributes)
    end

    it { expect(Ordering.new(order).cancel).to be_true }
  end
end
