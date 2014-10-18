class TwoFactor::Sms < ::TwoFactor
  OTP_LENGTH = 6

  attr_accessor :send_code_phase
  attr_accessor :phone_number

  validates_presence_of :phone_number, if: :send_code_phase
  validates :phone_number, phone: { possible: true,
                                    allow_blank: true,
                                    types: [:mobile] }

  def verify?
    if !expired? && otp_secret == otp
      touch(:last_verify_at)
      true
    else
      if otp.blank?
        errors.add :otp, :blank
      else
        errors.add :otp, :invalid
      end
      false
    end
  end

  def sms_message
    I18n.t('sms.verification_code', code: otp_secret)
  end

  def send_otp
    refresh! if expired?
    update_phone_number_to_member if send_code_phase
    AMQPQueue.enqueue(:sms_notification, phone: member.phone_number, message: sms_message)
  end

  private

  def update_phone_number_to_member
    phone = Phonelib.parse(phone_number)
    member.update phone_number: phone.sanitized.to_s
  end

  def gen_code
    self.otp_secret = OTP_LENGTH.times.map{ Random.rand(9) + 1 }.join
    self.refreshed_at = Time.now
  end

  def send_notification
    return if not self.activated_changed?

    if self.activated
      MemberMailer.sms_auth_activated(member.id).deliver
    else
      MemberMailer.sms_auth_deactivated(member.id).deliver
    end
  end
end
