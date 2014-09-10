class SessionsController < ApplicationController
  include SimpleCaptcha::ControllerHelpers

  before_action :auth_member!, only: :destroy
  before_action :auth_anybody!, only: [:new, :create, :failure]

  helper_method :require_captcha?

  def new
    @identity = Identity.new
  end

  def create
    if !require_captcha? || simple_captcha_valid?
      @member = Member.from_auth(env["omniauth.auth"])
    end

    if @member
      if @member.disabled?
        increase_failed_logins
        redirect_to signin_path, alert: t('.disabled')
      else
        clear_failed_logins
        session[:temp_member_id] = @member.id
        redirect_to new_verify_two_factor_path
      end
    else
      increase_failed_logins
      redirect_to signin_path, alert: t('.error')
    end
  end

  def failure
    increase_failed_logins
    redirect_to signin_path, alert: t('.error')
  end

  def setup
    save_session_key session[:member_id], cookies['_peatio_session']
    redirect_to settings_path
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def require_captcha?
    failed_logins > 3
  end

  def failed_logins
    Rails.cache.read(failed_login_key) || 0
  end

  def increase_failed_logins
    Rails.cache.write(failed_login_key, failed_logins+1)
  end

  def clear_failed_logins
    Rails.cache.delete failed_login_key
  end

  def failed_login_key
    "peatio:session:#{request.ip}:failed_logins"
  end

end
