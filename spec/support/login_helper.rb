def login(identity, password: nil)
  visit signin_path

  within 'form#new_identity' do
    fill_in 'identity_email', with: identity.email
    fill_in 'identity_password', with: (password || identity.password)
    click_on I18n.t('header.signin')
  end
end

def signout
  find('li.account-settings').click
  click_link I18n.t('header.signout')
end

def check_signin
  expect(page).not_to have_content(I18n.t('header.signin'))
end

alias signin login
