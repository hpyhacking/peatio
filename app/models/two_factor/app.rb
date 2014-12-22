class TwoFactor::App < ::TwoFactor

  def verify?
    return false if otp_secret.blank?

    rotp = ROTP::TOTP.new(otp_secret)

    if rotp.verify(otp)
      touch(:last_verify_at)
      true
    else
      errors.add :otp, :invalid
      false
    end
  end

  def uri
    totp = ROTP::TOTP.new(otp_secret)
    totp.provisioning_uri(member.email) + "&issuer=#{ENV['URL_HOST']}"
  end

  def now
    ROTP::TOTP.new(otp_secret).now
  end

  def refresh!
    return if activated?
    super
  end

  private

  def gen_code
    self.otp_secret = ROTP::Base32.random_base32
    self.refreshed_at = Time.new
  end

  def send_notification
    return if not self.activated_changed?

    if self.activated
      MemberMailer.google_auth_activated(member.id).deliver
    else
      MemberMailer.google_auth_deactivated(member.id).deliver
    end
  end

end
