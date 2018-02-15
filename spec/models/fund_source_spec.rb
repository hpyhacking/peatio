describe FundSource do
  context '#label' do
    context 'for btc' do
      let(:fund_source) { build(:btc_fund_source) }
      subject { fund_source.label }

      it { is_expected.to eq "#{fund_source.uid} (bitcoin)" }
    end

    context 'bank' do
      let(:fund_source) { build(:usd_fund_source) }
      subject { fund_source.label }

      it { is_expected.to eq 'bc#****1234' }
    end
  end
end
