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
    update otp_secret: gen_code, refreshed_at: Time.now
  end

  def uri
    totp = ROTP::TOTP.new(otp_secret)
    totp.provisioning_uri(member.email) + "&issuer=#{ENV['URL_HOST']}"
  end

  def now
    ROTP::TOTP.new(otp_secret).now
  end

  private

  def gen_code
    ROTP::Base32.random_base32
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
