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

class TwoFactor::App < ::TwoFactor

  def verify(otp = nil)
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
    totp.provisioning_uri("#{ENV['URL_HOST']}##{member.email}")
  end

  def now
    ROTP::TOTP.new(otp_secret).now
  end
end
