describe 'Sign in', type: :feature do
  let!(:identity) { create :identity }
  let!(:member) { create :member, email: identity.email, activated: true }

  it 'allows a user to sign in with email, password' do
    signin identity
    expect(current_path).to eq(settings_path)
  end

  it 'prevents a user to sign if his account is disabled' do
    member.update_attributes disabled: true
    signin identity
    expect(current_path).to eq(signin_path)
  end

  it 'sends notification email after user sign in' do
    signin identity

    mail = ActionMailer::Base.deliveries.last
    expect(mail).to be_present
    expect(mail.to).to eq([identity.email])
    expect(mail.subject).to eq(I18n.t('member_mailer.notify_signin.subject'))
  end

end
