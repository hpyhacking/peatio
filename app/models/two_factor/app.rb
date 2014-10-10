class TwoFactor::App < ::TwoFactor

  after_update :send_notification_after_change

  def verify(otp = nil)
    return false if otp_secret.blank?

    rotp = ROTP::TOTP.new(otp_secret)

    if rotp.verify(otp || self.otp)
      touch(:last_verify_at)
    else
      errors.add :otp, :invalid
      false
    end
  end

  def refresh
    update_attribute(:otp_secret, ROTP::Base32.random_base32)
  end

  def uri
    totp = ROTP::TOTP.new(otp_secret)
    totp.provisioning_uri(member.email) + "&issuer=#{ENV['URL_HOST']}"
  end

  def now
    ROTP::TOTP.new(otp_secret).now
  end

  def send_notification_after_change
    return if not self.activated_changed?

    if self.activated
      MemberMailer.google_auth_activated(member.id).deliver
    else
      MemberMailer.google_auth_deactivated(member.id).deliver
    end
  end

end
