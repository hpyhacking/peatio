class TwoFactor::Sms < ::TwoFactor
  OTP_LENGTH = 6

  def verify
    if refreshed_at && Time.now < 30.minutes.since(refreshed_at) && otp == otp_secret
      touch(:last_verify_at)
    else
      errors.add :otp, :invalid
      false
    end
  end

  def refresh
    update otp_secret: gen_code, refreshed_at: Time.now
  end

  def sms_message
    I18n.t('sms.verification_code', code: otp_secret)
  end

  def send_otp
    AMQPQueue.enqueue(:sms_notification, phone: member.phone_number, message: sms_message)
  end

  private

  def gen_code
    OTP_LENGTH.times.map{ Random.rand(9) + 1 }.join
  end
end
