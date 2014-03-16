class ResetPassword < Token
  attr_accessor :email
  attr_accessor :password
  attr_accessor :recaptcha

  validates :password, format: { with: Identity::PASSWORD_REGEX }, presence: true, on: :update
  after_update :reset_password

  private

  def reset_password
    self.member.identity.update_attributes \
      password: self.password, 
      password_confirmation: self.password
  end
end
