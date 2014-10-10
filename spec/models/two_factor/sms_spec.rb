require 'spec_helper'

describe TwoFactor::Sms do
  let(:member) { create :member }
  let(:two_factor) { create :two_factor_sms, member: member }
  before { two_factor.refresh }

  describe "#refresh" do
    subject { two_factor }

    its(:otp_secret) { should_not be_blank }
  end

  describe '#verify' do
    it "with wrong code" do
      two_factor.otp = 'foobar'
      expect(two_factor.verify).not_to be_true
    end

    it "with right code" do
      two_factor.otp = two_factor.otp_secret
      expect(two_factor.verify).to be_true
    end
  end

  describe '#sms_message' do
    its(:sms_message) { should_not be_blank }
  end

  describe '#activated' do
    let(:member) { create :member }
    let(:two_factor) { create :two_factor_sms, member: member }

    before do
      two_factor.deactive!
    end

    it { expect(two_factor).not_to be_activated }
    it { expect(member.sms_two_factor).not_to be_activated }
  end
end

