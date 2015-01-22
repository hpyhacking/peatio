require 'spec_helper'

describe '2-step verification' do
  let!(:identity) { create :identity }
  let!(:member) { create :member, email: identity.email }

  it 'allows user to set it up and disable it' do
    pending

    signin identity

    # enable
    within '#two_factor_auth' do
      click_on t('private.settings.index.two_factor_auth.enable')
    end

    secret = page.find('#two_factor_otp_secret').value
    fill_in 'two_factor_otp', with: ROTP::TOTP.new(secret).now
    click_on t('private.two_factors.new.submit')
    expect(page).to have_content t('private.two_factors.create.notice')

    # signin again
    signout
    signin identity, otp: ROTP::TOTP.new(secret).now

    # disable
    within '#two_factor_auth' do
      click_link t('private.settings.index.two_factor_auth.disable')
    end

    fill_in 'two_factor_otp', with: ROTP::TOTP.new(secret).now
    click_on t('private.two_factors.edit.submit')
    expect(page).to have_content t('private.two_factors.destroy.notice')

    signout
    signin identity
    check_signin
  end
end
