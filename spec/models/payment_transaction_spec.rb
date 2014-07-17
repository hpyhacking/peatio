# == Schema Information
#
# Table name: payment_transactions
#
#  id            :integer          not null, primary key
#  txid          :string(255)
#  amount        :decimal(32, 16)
#  confirmations :integer
#  address       :string(255)
#  state         :integer
#  aasm_state    :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  receive_at    :datetime
#  dont_at       :datetime
#  currency      :integer
#

require 'spec_helper'

describe PaymentTransaction do
  it "expect state transfer" do
    tx = create(:payment_transaction, deposit: create(:deposit))
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
end
