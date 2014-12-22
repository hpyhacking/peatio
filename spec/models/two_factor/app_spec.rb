require 'spec_helper'

describe TwoFactor::App do
  let(:member) { create :member }
  let(:app) { member.app_two_factor  }

  describe "generate code" do
    subject { app }

    its(:otp_secret) { should_not be_blank }
  end

  describe '#refresh' do
    context 'inactivated' do
      it {
        orig_otp_secret = app.otp_secret.dup
        app.refresh!
        expect(app.otp_secret).not_to eq(orig_otp_secret)
      }
    end

    context 'activated' do
      subject { create :two_factor_app, activated: true }

      it {
        orig_otp_secret = subject.otp_secret.dup
        subject.refresh!
        expect(subject.otp_secret).to eq(orig_otp_secret)
      }
    end
  end

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
      expect {
        expect(app).not_to be_nil
      }.to change(TwoFactor::App, :count).by(1)
    end

    it "retrieve exist one instead of creating" do
      two_factor = member.app_two_factor
      expect(member.app_two_factor).to eq(two_factor)
    end
  end

  describe '#active!' do
    subject { member.app_two_factor }
    before { subject.active! }

    its(:activated?) { should be_true }
  end

  describe '#deactive!' do
    subject { create :two_factor_app, activated: true }
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
