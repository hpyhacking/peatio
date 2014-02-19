require 'spec_helper'

describe '2-step verification' do
  let(:identity) { create :identity, member: create(:member) }

  it 'allows user to set it up and disable it' do
    login identity
    click_on identity.email
    expect(page).to_not have_content I18n.t('private.settings.index.two_factor_auth.disable')

    # set up
    click_on I18n.t('private.settings.index.two_factor_auth.configure')
    secret = page.find('code').text
    fill_in 'otp_otp', with: ROTP::TOTP.new(secret).now
    click_on I18n.t('helpers.submit.otp.update')
    expect(page.find('#notice')).to have_content I18n.t('private.settings.success')

    find('#sign_out').click
    login identity, ROTP::TOTP.new(secret).now

    click_on identity.email
    expect(page).to_not have_content I18n.t('private.settings.index.two_factor_auth.configure')

    # disable
    click_link I18n.t('private.settings.index.two_factor_auth.disable')
    fill_in 'password', with: "Password123"
    click_button I18n.t('private.settings.index.two_factor_auth.disable')
    expect(page).to have_content I18n.t('private.settings.index.two_factor_auth.configure')

    find('#sign_out').click
    login identity

    # login success, back to dashboard
    expect(page).to have_content(I18n.t('header.market'))
  end
end
