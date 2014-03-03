require 'spec_helper'

describe 'Sign in' do
  let!(:identity) { create(:identity) }
  let!(:user) { create :member, identity: identity }

  it 'allows a user to sign in with email, password' do
    login identity
    expect(current_path).to eq(settings_path)
  end

  context 'when a user has 2-step verification setup and after signing in with email, password' do
    before do
      two_factor = identity.create_two_factor
      two_factor.refresh
      two_factor.update_attributes(activated: true)

      login identity
    end

    it 'if he tries to perform 2-step verification after session expires, should redirect user back to login step with error message', js: true do
      clear_cookie

      otp = ROTP::TOTP.new(identity.two_factor.otp_secret).now
      fill_in 'identity_otp', with: otp
      click_on I18n.t('helpers.submit.identity.verify')

      expect(current_path).to eq(signin_path)
      expect(page).to have_content(I18n.t('sessions.create_with_two_factor_auth.session_expired'))
    end

    it 'allow user to disable it if they have lost their phone', js: true do
      click_on I18n.t 'sessions.new_with_two_factor_auth.reset_two_factor'

      fill_in 'reset_two_factor_email', with: identity.email
      fill_in 'reset_two_factor_skip', with: 'skip'
      click_on I18n.t 'helpers.submit.reset_two_factor.create'

      expect(current_path).to eq(signin_path)
      expect(page).to have_content(I18n.t('reset_two_factors.create.success'))

      mail = ActionMailer::Base.deliveries.last
      expect(mail).to be_present
      expect(mail.to).to eq([identity.email])
      expect(mail.subject).to eq(I18n.t 'token_mailer.reset_two_factor.subject')

      link = mail.body.to_s.match(/http:\/\/peatio\.dev(.*)/)[1]
      visit link

      expect(current_path).to eq(signin_path)
      expect(page).to have_content(I18n.t('reset_two_factors.edit.success'))
    end
  end

  it 'allows user to reset password after too many failed attempts', js: true do
    5.times do
      login identity, '', 'wrong'
    end
    expect(page).to have_content I18n.t('sessions.failure.account_locked')

    # try to login with correct password
    login identity
    expect(page).to have_content I18n.t('sessions.failure.account_locked')

    # reset password
    click_on I18n.t('sessions.new.reset_password')
    fill_in 'reset_password_email', with: identity.email
    fill_in 'reset_password_skip', with: 'skip'
    click_on I18n.t('helpers.submit.reset_password.create')

    # have to sleep again to get the correct mail =(
    sleep 1

    mail = ActionMailer::Base.deliveries.last
    link = mail.body.to_s.match(/http:\/\/peatio\.dev(.*)/)[1]
    visit link

    new_password = 'Password123456'
    fill_in 'reset_password_password', with: new_password
    click_on I18n.t('helpers.submit.reset_password.update')

    login identity, '', new_password
    expect(page).to have_content(I18n.t('header.market'))
  end
end
