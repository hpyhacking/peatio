class TwoFactor < ActiveRecord::Base
  belongs_to :member

  attr_accessor :otp

  SUBCLASS = ['app', 'sms', 'email', 'wechat']

  scope :activated, -> { where(activated: true) }

  class << self
    def by_type(type)
      return if not SUBCLASS.include?(type.to_s)

      klass = "two_factor/#{type}".camelize.constantize
      klass.first || klass.create(type: klass.name)
    end

    def activated?
      activated.any?
    end
  end

end
