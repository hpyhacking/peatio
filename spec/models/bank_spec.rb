require 'spec_helper'

describe Bank do
  context '#with_currency' do
    it { expect(Bank.with_currency(:eur)).not_to be_empty }
  end

  context '#currency_obj' do
    subject { Bank.with_currency(:eur).first }
    its(:currency_obj) { should be_present }
  end
end
