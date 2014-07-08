# == Schema Information
#
# Table name: two_factors
#
#  id             :integer          not null, primary key
#  member_id      :integer
#  otp_secret     :string(255)
#  last_verify_at :datetime
#  activated      :boolean
#  type           :string(255)
#

class TwoFactor::Sms < ::TwoFactor
  OTP_LENGTH = 6

  def verify
    if otp == otp_secret
      touch(:last_verify_at)
    else
      errors.add :otp, :invalid
      false
    end
  end

  def refresh
    update otp_secret: OTP_LENGTH.times.map{ Random.rand(9) + 1 }.join
  end

  def sms_message
    I18n.t('private.two_factors.auth.sms_message', code: otp_secret)
  end

  def send_otp
    AMQPQueue.enqueue(:sms_notification, phone: member.phone_number, message: sms_message)
  end
end
