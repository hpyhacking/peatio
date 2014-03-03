class Identity < OmniAuth::Identity::Models::ActiveRecord
  auth_key :email
  attr_accessor :otp

  PIN_REGEX = /\A[0123456789*#]{4,6}\z/
  PASSWORD_REGEX = /\A.*(?=.{8,})(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).*\z/
  MAX_LOGIN_ATTEMPTS = 5

  has_one :member
  has_one :two_factor
  has_one :activation, -> { where is_used: false }

  validates :email, presence: true, uniqueness: true, email: true
  validates :password, presence: true, format: { with: PASSWORD_REGEX }, on: :create
  validates :password_confirmation, presence: true, format: { with: PASSWORD_REGEX }, on: :create

  def direct_update_pin(pin)
    update_column(:pin_digest, BCrypt::Password.create(pin))
  end

  def direct_update_password(password)
    update_column(:password_digest, BCrypt::Password.create(password))
  end

  def direct_disable_otp
    self.two_factor && self.two_factor.update_attribute(:activated, false)
  end

  def has_active_two_factor_auth?
    self.two_factor && self.two_factor.activated?
  end

  ## verify GA
  def verify_otp(otp)
    two_factor = self.two_factor

    self.two_factor.otp = otp
    two_factor.verify
  end

  def increment_retry_count
    self.retry_count = (retry_count || 0) + 1
  end

  def too_many_failed_login_attempts
    retry_count.present? && retry_count >= MAX_LOGIN_ATTEMPTS
  end
end
