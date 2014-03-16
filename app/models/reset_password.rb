class ResetPassword < Token
  attr_accessor :email
  attr_accessor :password
  attr_accessor :recaptcha

  after_update :reset_password
  validates :password, format: { with: Identity::PASSWORD_REGEX }, presence: true, on: :update
  before_validation :set_tokenable_from_email

  private

  def set_tokenable_from_email
    if @email and @tokenable.nil?
      tokenable = Member.find_by_email(@email)
      unless tokenable
        self.errors.add(:email, :'not-member')
      else
        @tokenable = tokenable
      end
    end
  end

  def reset_password
    self.tokenable.identity.update_attributes \
      password: self.password, 
      password_confirmation: self.password
  end
end
