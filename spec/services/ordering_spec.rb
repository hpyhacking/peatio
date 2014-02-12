require 'spec_helper'

describe Ordering do
  let(:order) { create(:order_ask) }
  let(:account) { create(:account, balance: 100.to_d, locked: 100.to_d) }

  describe "ordering service can submit order" do
    before do order.stubs(:hold_account).returns(account) end
    it { expect(Ordering.new(order).submit).to_not be_false }
  end

  describe "ordering service can cancel order" do
    before do order.stubs(:hold_account).returns(account) end
    it { expect(Ordering.new(order).cancel).to_not be_false }
  end
end
