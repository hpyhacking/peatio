require 'spec_helper'

describe FundSource do

  context '#label' do
    context 'for btc' do
      let(:fund_source) { build(:btc_fund_source) }
      subject { fund_source }

      its(:label) { should eq("bitcoin##{fund_source.uid}") }
    end

    context 'bank' do
      let(:fund_source) { build(:cny_fund_source) }
      subject { fund_source }

      its(:label) { should eq('bank_code_1#****1234') }
    end
  end

end
