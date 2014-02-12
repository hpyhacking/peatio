class ResetPassword < Token
  attr_accessor :password

  validates :password, format: { with: Identity::PASSWORD_REGEX }, presence: true, on: :update
  after_update :reset_password

  private

  def reset_password
    self.identity.direct_update_password(self.password)
  end
end
