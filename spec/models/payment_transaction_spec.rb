require 'spec_helper'

describe PaymentTransaction do
  it "expect state transfer" do
    tx = FactoryGirl.create(:payment_transaction)
    tx.stubs(:refresh_confirmations)

    tx.stubs(:zero_confirm?).returns(true)
    tx.stubs(:min_confirm?).returns(false)
    tx.stubs(:max_confirm?).returns(false)

    expect(tx.unconfirm?).to be_true
    tx.check
    tx.check
    tx.check
    expect(tx.unconfirm?).to be_true

    tx.stubs(:zero_confirm?).returns(false)
    tx.stubs(:min_confirm?).returns(true)
    tx.stubs(:max_confirm?).returns(false)

    tx.check
    expect(tx.confirming?).to be_true

    tx.stubs(:zero_confirm?).returns(false)
    tx.stubs(:min_confirm?).returns(false)
    tx.stubs(:max_confirm?).returns(true)

    tx.check
    expect(tx.confirmed?).to be_true

    expect { tx.check }.to raise_error
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
      expect(tx.zero_confirm?).to be_true
      expect(tx.min_confirm?).to be_false
      expect(tx.max_confirm?).to be_false
    end

    it "expect min confirm" do
      tx.stubs(:confirmations).returns(1)

      expect(tx.zero_confirm?).to be_false
      expect(tx.min_confirm?).to be_true
      expect(tx.max_confirm?).to be_false
    end

    it "expect min confirm" do
      tx.stubs(:confirmations).returns(2)

      expect(tx.zero_confirm?).to be_false
      expect(tx.min_confirm?).to be_true
      expect(tx.max_confirm?).to be_false
    end

    it "expect max confirm" do
      tx.stubs(:confirmations).returns(3)

      expect(tx.zero_confirm?).to be_false
      expect(tx.min_confirm?).to be_false
      expect(tx.max_confirm?).to be_true
    end

    it "expect max confirm" do
      tx.stubs(:confirmations).returns(4)

      expect(tx.zero_confirm?).to be_false
      expect(tx.min_confirm?).to be_false
      expect(tx.max_confirm?).to be_true
    end
  end

  #it "expect check confirm count" do
    #tx = FactoryGirl.create(:payment_transaction)
    #tx.channel = stub(:min_confirm => 1, max_confirm => 3)
    #tx.stubs(:confirmations).returns(1)
  #end
end
