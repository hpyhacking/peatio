class ResetPassword < Token
  attr_accessor :email
  attr_accessor :password
  attr_accessor :recaptcha

  validates :password, format: { with: Identity::PASSWORD_REGEX }, presence: true, on: :update

  after_create :send_token
  after_update :reset_password

  private

  def reset_password
    Identity.find_by_email(self.member.email).update_attributes \
      password: self.password,
      password_confirmation: self.password
  end
end
