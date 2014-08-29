# == Schema Information
#
# Table name: fund_sources
#
#  id         :integer          not null, primary key
#  member_id  :integer
#  currency   :integer
#  extra      :string(255)
#  uid        :string(255)
#  is_locked  :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

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
