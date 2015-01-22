require 'spec_helper'

describe 'password' do
  let!(:identity) { create :identity }
  let!(:password) { 'New1Password' }
  let!(:member) { create :member, email: identity.email }

  it 'can be reset by user' do
    signin identity
    click_on t('private.settings.index.passwords.go')

    fill_in 'identity_old_password', with: identity.password
    fill_in 'identity_password', with: password
    fill_in 'identity_password_confirmation', with: password
    click_on t('helpers.submit.identity.update')
    expect(page).to have_content(t('identities.update.notice'))

    signin identity, password: password
    check_signin
  end
end
