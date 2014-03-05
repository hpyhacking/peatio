class Identity < OmniAuth::Identity::Models::ActiveRecord
  auth_key :email
  attr_accessor :old_password

  PASSWORD_REGEX = /\A.*(?=.{8,})(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).*\z/
  MAX_LOGIN_ATTEMPTS = 5

  validates :email, presence: true, uniqueness: true, email: true
  validates :password, presence: true, format: { with: PASSWORD_REGEX }
  validates :password_confirmation, presence: true, format: { with: PASSWORD_REGEX }

  def increment_retry_count
    self.retry_count = (retry_count || 0) + 1
  end

  def too_many_failed_login_attempts
    retry_count.present? && retry_count >= MAX_LOGIN_ATTEMPTS
  end
end
