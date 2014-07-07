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

class TwoFactor::Email < ::TwoFactor

end
