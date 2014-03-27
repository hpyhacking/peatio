require 'spec_helper'

describe Deposit do
  let(:deposit ) { create(:deposit, amount: 100.to_d) }

  it 'should build complate' do
    expect(deposit.channel).to_not be_nil
  end

  it 'should compute fee' do
    expect(deposit.fee).to eql 0.to_d
    expect(deposit.amount).to eql 100.to_d
  end

  context 'when deposit fee 10%' do
    let(:channel) { build(:deposit_channel) }
    let(:deposit) { create(:deposit, amount: 100.to_d, channel: channel) }

    before do
      channel.stubs(:compute_fee).returns [90, 10]
    end

    it 'should compute fee' do
      expect(deposit.fee).to eql 10
      expect(deposit.amount).to eql 90
    end
  end
end
