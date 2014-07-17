# == Schema Information
#
# Table name: identities
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  password_digest :string(255)
#  is_active       :boolean
#  retry_count     :integer
#  is_locked       :boolean
#  locked_at       :datetime
#  last_verify_at  :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

class Identity < OmniAuth::Identity::Models::ActiveRecord
  auth_key :email
  attr_accessor :old_password

  MAX_LOGIN_ATTEMPTS = 5

  validates :email, presence: true, uniqueness: true, email: true
  validates :password, presence: true, length: { minimum: 6, maximum: 64 }
  validates :password_confirmation, presence: true, length: { minimum: 6, maximum: 64 }

  def increment_retry_count
    self.retry_count = (retry_count || 0) + 1
  end

  def too_many_failed_login_attempts
    retry_count.present? && retry_count >= MAX_LOGIN_ATTEMPTS
  end
end
