require 'spec_helper'

describe Worker::DepositBitshares do

  subject { Worker::DepositBitshares.new 'btsx' }

  context '#destruct_memo' do
    let(:account) { create(:member).get_account('btc') }
    let!(:memo)   { subject.construct_memo account }

    it "returns the corresponding account if memo is valid" do
      subject.destruct_memo(memo).should == account
    end

    it "returns nil if size bit is missing" do
      wrong_memo = memo[0..-2]
      subject.destruct_memo(wrong_memo).should be_nil
    end
  end

end
