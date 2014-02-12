class TwoFactor < ActiveRecord::Base
  belongs_to :identity

  attr_accessor :otp

  def verify
    if ROTP::TOTP.new(otp_secret).verify(otp)
      update_attribute(:is_active, true)
      touch(:last_verify_at)
      return true
    end

    return false
  end

  def refresh
    update_attribute(:otp_secret, ROTP::Base32.random_base32) unless is_active
  end

  def uri
    totp = ROTP::TOTP.new(self.otp_secret)
    totp.provisioning_uri("PEATIO / #{identity.email}")
  end
end
