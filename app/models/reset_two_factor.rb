class ResetTwoFactor < Token
  after_update :reset_two_factor

  private

  def reset_two_factor
    tokenable.identity.direct_disable_otp
  end
end

