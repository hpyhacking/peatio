class TwoFactor < ActiveRecord::Base
  belongs_to :member

  attr_accessor :otp

  def verify
    rotp = ROTP::TOTP.new(self.otp_secret)

    if rotp.verify(self.otp)
      touch(:last_verify_at)
    else
      false
    end
  end

  def refresh
    update_attribute(:otp_secret, ROTP::Base32.random_base32)
  end

  def uri
    totp = ROTP::TOTP.new(self.otp_secret)
    totp.provisioning_uri("PEATIO / #{member.email}")
  end

  def now
    ROTP::TOTP.new(self.otp_secret).now
  end
end
