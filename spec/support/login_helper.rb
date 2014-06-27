def login(identity, otp: nil, password: nil)
  visit root_path
  click_on I18n.t('header.signin')
  expect(URI(current_path).path).to eq(URI(signin_path).path)

  within 'form#new_identity' do
    fill_in 'identity_email', with: identity.email
    fill_in 'identity_password', with: (password || identity.password)
    click_on I18n.t('header.signin')
  end

  if otp
    fill_in 'two_factor_otp', with: otp
    click_on I18n.t('helpers.submit.two_factor.create')
  end
end

def signout
  click_link t('header.signout')
end

def check_signin
  expect(page).to have_content(I18n.t('header.signout'))
end

alias :signin :login
