class SmsToken < Token

  VERIFICATION_CODE_LENGTH = 6

  attr_accessor :phone_number
  attr_accessor :verify_code

  validates_uniqueness_of :token, scope: :member_id
  validates :phone_number, phone: { possible: true, allow_blank: true, types: [:mobile] }

  class << self
    def for_member(member)
      return member.create_sms_token if member.sms_token.blank?

      if member.sms_token && !member.sms_token.expired?
        member.sms_token
      else
        member.sms_token.destroy
        member.create_sms_token
      end
    end
  end

  def generate_token
    begin
      self.is_used = false
      self.token = VERIFICATION_CODE_LENGTH.times.map{ Random.rand(9) + 1 }.join
      self.expire_at = DateTime.now.since(60 * 30)
    end while SmsToken.where(member_id: member_id, token: token).any?
  end

  def expired?
    expire_at <= Time.now
  end

  def update_phone_number
    phone = Phonelib.parse(phone_number)
    member.update phone_number: phone.sanitized.to_s
  end

  def send_verify_code
    AMQPQueue.enqueue(:sms_notification, phone: member.phone_number, message: sms_message)
  end

  def sms_message
    I18n.t('verify.sms_tokens.new.sms_message', code: token)
  end

  def verify?
    if token == verify_code
      true
    else
      errors.add(:verify_code, I18n.t("errors.messages.invalid"))
      false
    end
  end

  def verified!
    member.update phone_number_verified: true
    self.update is_used: true
  end

end
