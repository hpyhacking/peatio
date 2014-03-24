require 'spec_helper'

describe 'Sign in' do
  let!(:identity) { create :identity }
  let!(:member) { create :member, email: identity.email, activated: true }

  it 'allows a user to sign in with email, password' do
    signin identity
    expect(current_path).to eq(settings_path)
  end

  it "sends notification email after user sign in" do
    signin identity

    mail = ActionMailer::Base.deliveries.last
    expect(mail).to be_present
    expect(mail.to).to eq([identity.email])
    expect(mail.subject).to eq(I18n.t 'member_mailer.notify_signin.subject')
  end

  context 'when a user has 2-step verification setup and after signing in with email, password' do
    let!(:member) { create :member, email: identity.email }
    let!(:two_factor) { create :two_factor, member: member }

    it 'if he tries to perform 2-step verification after session expires, should redirect user back to login step with error message', js: true do
      signin identity
      clear_cookie

      fill_in 'two_factor_otp', with: two_factor.now
      click_on I18n.t('helpers.submit.two_factor.create')

      expect(current_path).to eq(signin_path)
      expect(page).to have_content(t('verify.two_factors.create.timeout'))
    end
  end

  it 'locked member after too many failed attempts', js: true do
    pending "delay password failed counter" and return
    5.times do signin identity, password: 'wrong' end
    expect(page).to have_content I18n.t('sessions.failure.account_locked')

    signin identity
    expect(page).to have_content I18n.t('sessions.failure.account_locked')
  end
end
