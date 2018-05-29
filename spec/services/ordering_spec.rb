# encoding: UTF-8
# frozen_string_literal: true

describe Ordering do
  let(:order) { create(:order_bid, volume: '1.23456789', price: '1.23456789') }
  let(:account) { create_account(:usd, balance: 100.to_d, locked: 100.to_d) }

  describe 'ordering service can submit order' do
    before do
      order.stubs(:hold_account).returns(account)
      order.stubs(:hold_account!).returns(account.lock!)
      AMQPQueue.expects(:enqueue).with(:matching, anything).once
    end

    it 'should return true on success' do
      expect(Ordering.new(order).submit).to be true
    end

    it 'should set locked funds on order' do
      Ordering.new(order).submit
      expect(order.locked).to eq order.compute_locked
      expect(order.origin_locked).to eq order.compute_locked
    end

    it 'should compute locked after number precision fixed' do
      Ordering.new(order).submit
      expect(order.reload.locked).to eq '1.52399025'.to_d
    end
  end

  describe 'ordering service can cancel order' do
    before do
      order.stubs(:hold_account!).returns(account.lock!)
    end

    it 'should soft cancel order' do
      AMQPQueue.expects(:enqueue).with(:matching, action: 'cancel', order: order.to_matching_attributes)
      Ordering.new(order).cancel
    end

    it 'should hard cancel order' do
      Ordering.new(order).cancel!
      expect(order.reload.state).to eq Order::CANCEL
      expect(account.reload.locked).to eq ('100'.to_d - order.locked)
    end
  end
end
