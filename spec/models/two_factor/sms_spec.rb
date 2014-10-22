require 'spec_helper'

describe TwoFactor::Sms do
  let(:member) { create :member }
  let(:two_factor) { member.sms_two_factor }

  describe "#refresh" do
    subject { two_factor }

    its(:otp_secret) { should_not be_blank }
    it {
      orig_otp_secret = two_factor.otp_secret.dup
      two_factor.refresh!
      expect(two_factor.otp_secret).not_to eq(orig_otp_secret)
    }
  end

  describe "#phone_number" do
    subject {
      two_factor.phone_number = '123-1234-1234'
      two_factor
    }

    its(:phone_number) { should_not be_blank }
  end

  describe "#update member's phone_number when send_otp" do
    subject {
      two_factor.phone_number = '123-1234-1234'
      two_factor.send_otp
      two_factor
    }

    it { expect(member.phone_number).not_to be_blank }
  end

  describe '#verify?' do
    describe 'invalid code' do
      subject {
        two_factor.otp = 'foobar'
        two_factor
      }

      it { should_not be_verify }
    end

    describe 'verify succeed' do
      subject {
        two_factor.otp = two_factor.otp_secret
        two_factor
      }

      it { should be_verify }
    end
  end

  describe '#sms_message' do
    its(:sms_message) { should_not be_blank }
  end

  describe '#activated' do
    let(:member) { create :member }
    subject {
      two_factor = member.sms_two_factor
      two_factor.deactive!
      two_factor
    }

    it { expect(subject).not_to be_activated }
    it { expect(member.sms_two_factor).not_to be_activated }
  end
end

