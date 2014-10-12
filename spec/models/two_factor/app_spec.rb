require 'spec_helper'

describe TwoFactor::App do
  let(:member) { create :member }
  let(:app) { member.app_two_factor  }

  describe 'uniq validate' do
    let(:member) { create :member }

    it "reject duplicate creation" do
      duplicate = TwoFactor.new app.attributes
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

  describe '#active!' do
    subject { create :two_factor }
    before { subject.active! }

    its(:activated?) { should be_true }
  end

  describe '#deactive!' do
    subject { create :two_factor, activated: true }
    before { subject.deactive! }

    its(:activated?) { should_not be_true }
  end

  describe '.activated' do
    before { create :member, :app_two_factor_activated }

    it "should has activated" do
      expect(TwoFactor.activated?).to be_true
    end
  end

  describe 'send_notification_mail' do
    let(:mail) { ActionMailer::Base.deliveries.last }

    describe "activated" do
      before { app.active! }

      it { expect(mail.subject).to match('Google authenticator activated') }
    end

    describe "deactived" do
      let(:member) { create :member, :app_two_factor_activated }
      before { app.deactive! }

      it { expect(mail.subject).to match('Google authenticator deactivated') }
    end
  end

end
