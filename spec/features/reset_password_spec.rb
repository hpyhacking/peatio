describe 'password', type: :feature do
  let!(:identity) { create :identity }
  let!(:password) { 'New1Password' }
  let!(:member) { create :member, email: identity.email }

  it 'can be reset by user' do
    signin identity
    click_on I18n.t('private.settings.index.passwords.go')

    fill_in 'identity_old_password', with: identity.password
    fill_in 'identity_password', with: password
    fill_in 'identity_password_confirmation', with: password
    click_on I18n.t('helpers.submit.identity.update')
    expect(page).to have_content(I18n.t('identities.update.notice'))

    signin identity, password: password
    check_signin
  end
end
