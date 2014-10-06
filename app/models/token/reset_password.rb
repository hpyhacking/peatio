class Token::ResetPassword < ::Token
  attr_accessor :email
  attr_accessor :password

  validates :password, presence: true,
                       on: :update,
                       length: { minimum: 6, maximum: 64 }

  after_create :send_token
  after_update :reset_password

  private

  def reset_password
    self.member.identity.update_attributes \
      password: self.password,
      password_confirmation: self.password
  end
end
