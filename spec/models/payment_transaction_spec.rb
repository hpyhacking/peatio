require 'spec_helper'

describe PaymentTransaction do
  it "expect state transfer" do
    tx = FactoryGirl.create(:payment_transaction)
    tx.stubs(:refresh_confirmations)

    tx.stubs(:min_confirm?).returns(false)
    tx.stubs(:max_confirm?).returns(false)

    expect(tx.unconfirm?).to be_true
    expect(tx.check).to be_false
    expect(tx.check).to be_false
    expect(tx.check).to be_false
    expect(tx.unconfirm?).to be_true

    tx.stubs(:min_confirm?).returns(true)
    tx.stubs(:max_confirm?).returns(false)

    expect(tx.check).to be_true
    expect(tx.confirming?).to be_true

    tx.stubs(:min_confirm?).returns(false)
    tx.stubs(:max_confirm?).returns(true)

    expect(tx.check).to be_true
    expect(tx.confirmed?).to be_true
    expect(tx.check).to be_true
  end

  describe '#confirm' do
    let(:tx) { create(:payment_transaction) }

    before do
      tx.channel.stubs(:min_confirm).returns(1)
      tx.channel.stubs(:max_confirm).returns(3)
      tx.stubs(:refresh_confirmations)
    end

    it "expect zero confirm" do
      tx.stubs(:confirmations).returns(0)
      expect(tx.min_confirm?).to be_false
      expect(tx.max_confirm?).to be_false
    end

    it "expect min confirm" do
      tx.stubs(:confirmations).returns(1)

      expect(tx.min_confirm?).to be_true
      expect(tx.max_confirm?).to be_false
    end

    it "expect min confirm" do
      tx.stubs(:confirmations).returns(2)

      expect(tx.min_confirm?).to be_true
      expect(tx.max_confirm?).to be_false
    end

    it "expect max confirm" do
      tx.stubs(:confirmations).returns(3)

      expect(tx.min_confirm?).to be_false
      expect(tx.max_confirm?).to be_true
    end

    it "expect max confirm" do
      tx.stubs(:confirmations).returns(4)

      expect(tx.min_confirm?).to be_false
      expect(tx.max_confirm?).to be_true
    end
  end
end
