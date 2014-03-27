require 'spec_helper'

describe DepositChannel do
  let(:channel) { build(:deposit_channel) }
  it 'should return self by get' do
    expect(channel.class.get).to eql channel
  end

  it 'should return key' do
    expect(channel.key).to eql 'default'
  end
end

