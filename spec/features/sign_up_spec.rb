require 'spec_helper'

describe 'Sign up', js: true do

  let(:identity) { build(:identity) }
  let(:number) { '18602826749' }
  let(:mobile_identity) { build(:identity, login: number) }

  def fill_in_sign_up_form(mobile = false)
    visit root_path
    click_on I18n.t('header.signup')

    within('form#new_identity') do
      fill_in 'login', with: mobile ? mobile_identity.login : identity.login
      fill_in 'password', with: mobile ? mobile_identity.password : identity.password
      fill_in 'password_confirmation', with: mobile ? mobile_identity.password_confirmation : identity.password_confirmation
      click_on I18n.t('header.signup')
    end
  end

  def email_activation_link
    mail = ActionMailer::Base.deliveries.last
    expect(mail).to be_present
    expect(mail.to).to eq([identity.login])
    expect(mail.subject).to eq(I18n.t 'token_mailer.activation.subject')

    path = "/activations/#{Token::Activation.last.token}/edit"
    link = "#{ENV['URL_SCHEMA']}://#{ENV['URL_HOST']}#{path}"

    expect(mail.body.to_s).to have_link(link)

    path
  end

  it 'allows a user to sign up and activate the account' do
    fill_in_sign_up_form
    visit email_activation_link
    check_signin
  end

  it 'allows a user to sign up and activate the account in a different browser' do
    fill_in_sign_up_form
    clear_cookie
    visit email_activation_link
    expect(page).to have_content(t('activations.edit.notice'))

    signin identity
    check_signin
  end

  it 'allows user to resend confirmation email' do
    fill_in_sign_up_form

    first_activation_link = email_activation_link

    Timecop.travel(31.minutes.from_now)

    click_on t('private.settings.index.email.resend')

    link = email_activation_link
    expect(link).to_not eq(first_activation_link)

    visit email_activation_link
    check_signin
  end

  describe "Signup with mobile phone number" do
    let!(:existing_member) { create(:activated_member) }
    let(:member) { Member.last }
    let(:new_identity) { Identity.last }

    context "Signing up with phone number"

    it "should be success for signining up with phone number" do
      fill_in_sign_up_form(true)

      expect(page).to have_content Phonelib.parse("86#{number}").national
      expect(member.phone_number).to eq("86#{number}")
      expect(member.phone_number_activated?).to eq(false)
      expect(new_identity.login).to eq(number)
      expect(member.authentications.last.provider).to eq('identity')
      expect(member.authentications.last.uid).to eq(new_identity.id.to_s)

    end

    specify "User can active the phone number after sigining up with phone number" do
      fill_in_sign_up_form(true)

      click_on 'verify_sms_auth'

      expect(page).to have_content I18n.t("guides.verify.sms_auths.panel")
      expect(page).to have_content Phonelib.parse("86#{number}").national

      click_on I18n.t("two_factors.auth.send_code")

      sleep(1.second)

      fill_in 'sms_auth_otp', with: TwoFactor::Sms.order("refreshed_at DESC").first.otp_secret

      click_on I18n.t("verify.sms_auths.show.submit")

      sleep(1.second)

      expect(member.phone_number_activated?).to eq(true)
      expect(member.sms_two_factor.activated?).to eq(true)
    end

    specify "User can bind email after sigining up with phone number without activing phone number." do
      fill_in_sign_up_form(true)

      click_on 'set_email'

      fill_in 'email_address', with: identity.login

      click_on I18n.t("verify.sms_auths.show.submit")

      visit email_activation_link

      sleep(1.second)

      expect(member.email).to eq(identity.login)
      expect(member.email_activated?).to eq(true)
      expect(member.phone_number_activated?).to eq(false)

    end

    specify "User can not bind a email which is already bound by other user" do
      fill_in_sign_up_form(true)

      click_on 'set_email'

      fill_in 'email_address', with: existing_member.email

      click_on I18n.t("verify.sms_auths.show.submit")

      expect(member.email).to eq(nil)
      expect(member.email_activated?).to eq(false)
      expect(member.phone_number).not_to eq(nil)
      expect(member.phone_number_activated?).to eq(false)
    end
  end

  describe "Signup with email" do
    let(:member) { Member.last }
    let(:new_identity) { Identity.last }
    specify "After signup with email, user can bind mobile without active email" do
      # signup with email
      fill_in_sign_up_form
      expect(member.email).to eq(identity.login)
      expect(member.email_activated?).to eq(false)

      # bind phone number
      visit settings_path
      click_on 'verify_sms_auth'
      expect(page).to have_content I18n.t("guides.verify.sms_auths.panel")
      fill_in 'sms_auth_phone_number', with: number
      click_on I18n.t("two_factors.auth.send_code")
      sleep(1.second)
      member.reload
      # verify the phone_number has been saved to member after sending
      expect(member.phone_number).to eq("86#{number}")

      fill_in 'sms_auth_otp', with: TwoFactor::Sms.order("refreshed_at DESC").first.otp_secret
      click_on I18n.t("verify.sms_auths.show.submit")

      sleep(1.second)
      member.reload

      # verify the phone_number has been activated
      expect(member.phone_number_activated?).to eq(true)
      expect(member.sms_two_factor.activated?).to eq(true)

    end

    specify "After signup with email, user can't bind a mobile which has already been taken." do
      create(:activated_member, phone_number: "86#{number}")
      create(:identity, login: number)

      fill_in_sign_up_form
      # bind a taken phonenumber
      visit settings_path
      click_on 'verify_sms_auth'
      expect(page).to have_content I18n.t("guides.verify.sms_auths.panel")
      fill_in 'sms_auth_phone_number', with: number
      click_on I18n.t("two_factors.auth.send_code")
      sleep(1.second)
      expect(page).to have_content(I18n.t("verify.sms_auths.show.notice.already_taken"))
      expect(member.phone_number).to eq(nil)
      expect(member.phone_number_activated?).to eq(false)
    end
  end

end
