# == Schema Information
#
# Table name: two_factors
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  otp_secret     :string(255)
#  last_verify_at :datetime
#  activated      :boolean
#  type           :string(255)
#

require 'spec_helper'

describe TwoFactor do

  describe 'uniq validate' do
    let(:member) { create :member }
    let(:two_factor) { member.two_factors.by_type(:app) }

    it "reject duplicate two_factor" do
      duplicate = TwoFactor.new two_factor.attributes
      expect(duplicate).not_to be_valid
    end
  end

  describe 'self.fetch_by_type' do
    it "return nil for wrong type" do
      expect(TwoFactor.by_type(:foobar)).to be_nil
    end

    it "create new one by type" do
      expect(TwoFactor.by_type(:app)).not_to be_nil
    end

    it "find exist one by tyep" do
      two_factor = TwoFactor::App.create
      expect(TwoFactor.by_type(:app)).to eq(two_factor)
    end
  end

  describe '.activiated' do
    before { create :member, :two_factor_activated }

    it "should has activated" do
      expect(TwoFactor.activated?).to be_true
    end
  end

  describe '#active!' do
    subject { create :two_factor }
    before { subject.active! }

    its(:activated?) { should be_true }
  end

  describe '#inactive!' do
    subject { create :two_factor, activated: true }
    before { subject.inactive! }

    its(:activated?) { should_not be_true }
  end

end

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
end
