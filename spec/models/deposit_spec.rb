# encoding: UTF-8
# frozen_string_literal: true

describe Deposit do
  let(:member) { create(:member) }
  let(:amount) { 100.to_d }
  let(:deposit) { create(:deposit_usd, member: member, amount: amount, currency: currency) }
  let(:currency) { Currency.find(:usd) }

  it 'computes fee' do
    expect(deposit.fee).to eql 0.to_d
    expect(deposit.amount).to eql 100.to_d
  end

  context 'fee is set to fixed value of 10' do
    before { Currency.any_instance.expects(:deposit_fee).once.returns(10) }

    it 'computes fee' do
      expect(deposit.fee).to eql 10.to_d
      expect(deposit.amount).to eql 90.to_d
    end
  end

  context 'fee exceeds amount' do
    before { Currency.any_instance.expects(:deposit_fee).once.returns(1.1) }
    let(:amount) { 1 }
    let(:deposit) { build(:deposit_usd, member: member, amount: amount, currency: currency) }
    it 'fails validation' do
      expect(deposit.save).to eq false
      expect(deposit.errors.full_messages).to eq ['Amount must be greater than 0.0']
    end
  end

  it 'automatically generates TID if it is blank' do
    expect(create(:deposit_btc).tid).not_to be_blank
  end

  it 'doesn\'t generate TID if it is not blank' do
    expect(create(:deposit_btc, tid: 'TID1234567890xyz').tid).to eq 'TID1234567890xyz'
  end

  it 'validates uniqueness of TID' do
    record1 = create(:deposit_btc)
    record2 = build(:deposit_btc, tid: record1.tid)
    record2.save
    expect(record2.errors.full_messages.first).to match(/tid has already been taken/i)
  end

  it 'uppercases automatically generated TID' do
    record = create(:deposit_btc)
    expect(record.tid).to eq record.tid.upcase
  end
end
