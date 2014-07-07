# == Schema Information
#
# Table name: deposits
#
#  id         :integer          not null, primary key
#  account_id :integer
#  member_id  :integer
#  currency   :integer
#  amount     :decimal(32, 16)
#  fee        :decimal(32, 16)
#  fund_uid   :string(255)
#  fund_extra :string(255)
#  txid       :string(255)
#  state      :integer
#  aasm_state :string(255)
#  created_at :datetime
#  updated_at :datetime
#  done_at    :datetime
#  memo       :string(255)
#  type       :string(255)
#

require 'spec_helper'

describe Deposit do
  let(:deposit ) { create(:deposit, amount: 100.to_d) }

  it 'should compute fee' do
    expect(deposit.fee).to eql 0.to_d
    expect(deposit.amount).to eql 100.to_d
  end

  context 'when deposit fee 10%' do
    let(:deposit) { create(:deposit, amount: 100.to_d) }

    before do
      Deposit.any_instance.stubs(:calc_fee).returns([90, 10])
    end

    it 'should compute fee' do
      expect(deposit.fee).to eql 10.to_d
      expect(deposit.amount).to eql 90.to_d
    end
  end
end
