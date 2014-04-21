class TwoFactor < ActiveRecord::Base
  belongs_to :member

  attr_accessor :otp
end
