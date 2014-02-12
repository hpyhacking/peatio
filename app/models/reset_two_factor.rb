class ResetTwoFactor < Token
  after_update :reset_two_factor

  private

  def reset_two_factor
    self.identity.direct_disable_otp
  end
end

