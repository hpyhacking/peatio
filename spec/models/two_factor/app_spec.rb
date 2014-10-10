require 'spec_helper'

describe TwoFactor::App do
  let(:member) { create :member }
  let(:app) { member.app_two_factor  }

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
