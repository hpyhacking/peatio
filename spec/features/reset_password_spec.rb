require 'spec_helper'

describe 'password', js: true do # need to be js because of recaptcha
  let(:identity) { create :identity, member: create(:member) }

  it 'can be reset by user' do
    login identity
    click_on I18n.t('header.settings')
    click_on I18n.t('private.settings.index.reset_password')

    fill_in 'reset_password_email', with: identity.email
    fill_in 'recaptcha_response_field', with: 'skip'
    click_on I18n.t('helpers.submit.reset_password.create')
    expect(page).to have_content(I18n.t 'reset_passwords.create.success')

    mail = ActionMailer::Base.deliveries.last
    expect(mail).to be_present
    expect(mail.to).to eq([identity.email])
    expect(mail.subject).to eq(I18n.t 'token_mailer.reset_password.subject')

    link = mail.body.to_s.match(/http:\/\/peatio\.dev(.*)/)[1]
    visit link

    new_password = 'Password123456'
    fill_in 'reset_password_password', with: new_password
    click_on I18n.t('helpers.submit.reset_password.update')

    find('#sign_out').click
    login identity, '', new_password
    expect(page).to have_content(I18n.t('header.market'))
  end
end
