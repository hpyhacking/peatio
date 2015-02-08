class TwoFactor::Sms < ::TwoFactor
  attr_accessor :send_code_phase
  attr_accessor :country, :phone_number

  validates_presence_of :phone_number, if: :send_code_phase
  validate :valid_phone_number_for_country

  def verify?
    if !expired? && otp_secret == otp
      touch(:last_verify_at)
      refresh!
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

  def valid_phone_number_for_country
    return if not send_code_phase

    if Phonelib.invalid_for_country?(phone_number, country)
      errors.add :phone_number, :invalid
    end
  end

  def country_code
    ISO3166::Country[country].try :country_code
  end

  def update_phone_number_to_member
    phone = Phonelib.parse([country_code, phone_number].join)
    member.update phone_number: phone.sanitized.to_s
  end

  def gen_code
    self.otp_secret = '%06d' % SecureRandom.random_number(1000000)
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
