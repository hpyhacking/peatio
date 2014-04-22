class TwoFactor::Sms < ::TwoFactor
  VERIFICATION_CODE_LENGTH = 6

  def verify
    if otp == otp_secret
      touch(:last_verify_at)
    else
      errors.add :otp, :invalid
      false
    end

  end

  def refresh
    begin
      self.otp_secret = VERIFICATION_CODE_LENGTH.times.map{ Random.rand(9) + 1 }.join
    end while TwoFactor::Sms.where(member_id: member_id, otp_secret: otp_secret).any?

  end

end
