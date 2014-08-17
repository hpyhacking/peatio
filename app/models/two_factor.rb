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

class TwoFactor < ActiveRecord::Base
  belongs_to :member

  attr_accessor :otp

  SUBCLASS = ['app', 'sms', 'email', 'wechat']

  validates_uniqueness_of :type, scope: :member_id

  scope :activated, -> { where(activated: true) }

  class << self
    def by_type(type)
      return if not SUBCLASS.include?(type.to_s)

      klass = "two_factor/#{type}".camelize.constantize
      klass.find_or_create_by(type: klass.name)
    end

    def activated?
      activated.any?
    end
  end

  def active!
    update activated: true
  end

  def deactive!
    update activated: false
  end

end
