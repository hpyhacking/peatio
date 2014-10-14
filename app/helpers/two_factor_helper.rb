module TwoFactorHelper

  def two_factor_tag(user)
    locals = {
      app_activated: user.app_two_factor.activated?,
      sms_activated: user.sms_two_factor.activated?
    }
    render partial: 'shared/two_factor_auth', locals: locals
  end

end
