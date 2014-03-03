def login identity, otp=nil, password='Password123'
  visit root_path
  click_on I18n.t('header.signin')
  expect(current_path).to eq(signin_path)

  within 'form#new_identity' do
    fill_in 'identity_email', with: identity.email
    fill_in 'identity_password', with: identity.password
    click_on I18n.t('header.signin')
  end

  unless otp
    fill_in 'identity_otp', with: otp
    click_on I18n.t('helpers.submit.identity.verify')
  end
end

alias :signup :login
