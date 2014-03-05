require 'spec_helper'

describe 'Sign up', js: true do
  before { Resque.inline = true } # doesn't work

  let(:identity) { build(:identity) }

  def fill_in_sign_up_form
    visit root_path
    click_on I18n.t('header.signup')

    within('form#new_identity') do
      fill_in 'email', with: identity.email
      fill_in 'password', with: identity.password
      fill_in 'password_confirmation', with: identity.password_confirmation
      click_on I18n.t('header.signup')
    end
  end

  def email_activation_link
    mail = ActionMailer::Base.deliveries.last
    expect(mail).to be_present
    expect(mail.to).to eq([identity.email])
    expect(mail.subject).to eq(I18n.t 'token_mailer.activation.subject')

    mail.body.to_s.match(/http:\/\/peatio\.dev(.*)/)[1]
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

    Timecop.travel(6.minutes.from_now)

    click_on t('private.settings.index.email.resend')

    link = email_activation_link
    expect(link).to_not eq(first_activation_link)

    visit email_activation_link
    check_signin
  end

  after { Resque.inline = false }
end
