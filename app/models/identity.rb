class Identity < OmniAuth::Identity::Models::ActiveRecord
  LOGIN_TYPE = [:email, :phone_number]
  MAX_LOGIN_ATTEMPTS = 5

  extend Enumerize

  auth_key :login
  attr_accessor :old_password, :skip_taken_check

  enumerize :login_type, in: LOGIN_TYPE, scope: true

  validates :login, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6, maximum: 64 }
  validates :password_confirmation, presence: true, length: { minimum: 6, maximum: 64 }
  validates :login_type, presence: true

  before_validation :sanitize
  before_validation :set_login_type
  before_create :check_if_number_has_been_taken, unless: :skip_taken_check
  before_create :format_phone_number_login

  attr_accessor :country


  def increment_retry_count
    self.retry_count = (retry_count || 0) + 1
  end

  def too_many_failed_login_attempts
    retry_count.present? && retry_count >= MAX_LOGIN_ATTEMPTS
  end

  def info
    {
      "email" => email,
      "phone_number" => phone_number,
      "country" => self.country
    }
  end

  def email
    self.login_type.email? ? self.login : nil
  end

  def phone_number
    self.login_type.phone_number? ? self.login : nil
  end

  def email=(e)
    self.login = e
  end

  def phone_number=(pn)
    self.login = ph
  end

  private

  def set_login_type
    if login =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      self.login_type = 'email'
    elsif login =~ /^\d+$/
      self.login_type = 'phone_number'
    else
      self.login_type = nil
    end
  end

  def check_if_number_has_been_taken
    if self.login_type == 'phone_number'
      number = Phonelib.parse([ISO3166::Country[self.country].try(:country_code), self.login].join)
      if Member.where(phone_number: number.original).first
        errors.add :login, :number_taken
        false
      end
    end
  end

  def format_phone_number_login
    if self.login_type == 'phone_number'
      number = Phonelib.parse self.login
      login_number = number.country == "CN" ? number.national : number.original
      self.login = login_number.gsub(/\s+/, "").gsub(/\+/, "") # remove spaces, and the '+' in the front
    end
  end

  def sanitize
    self.login.try(:downcase!)
  end

end
