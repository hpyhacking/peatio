module TwoFactorHelper

  def two_factor_tag(user)
    locals = {
      app_activated: user.app_two_factor.activated?,
      sms_activated: user.sms_two_factor.activated?
    }
    render partial: 'shared/two_factor_auth', locals: locals
  end

  def unlock_two_factor!
    session[:two_factor_unlock] = true
    session[:two_factor_unlock_at] = Time.now
  end

  def two_factor_locked?(expired_at: 5.minutes)
    locked  = !session[:two_factor_unlock]
    expired = session[:two_factor_unlock_at].nil? ? true : session[:two_factor_unlock_at] < expired_at.ago

    if !locked and !expired
      session[:two_factor_unlock_at] = Time.now
    end

    locked or expired
  end

end
