class SessionsController < ApplicationController

  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :auth_member!, only: :destroy
  before_action :auth_anybody!, only: [:new, :failure]

  helper_method :require_captcha?

  def new
    @identity = Identity.new
  end

  def create
    if !require_captcha? || simple_captcha_valid?
      @member = Member.from_auth(auth_hash)
    end

    if @member
      if @member.disabled?
        increase_failed_logins
        redirect_to signin_path, alert: t('.disabled')
      else
        clear_failed_logins
        reset_session rescue nil
        session[:member_id] = @member.id
        save_session_key @member.id, cookies['_peatio_session']
        save_signup_history @member.id
        MemberMailer.notify_signin(@member.id).deliver if @member.activated?
        redirect_on_successful_sign_in
      end
    else
      increase_failed_logins
      redirect_on_unsuccessful_sign_in
    end
  end

  def failure
    increase_failed_logins
    redirect_to signin_path, alert: t('.error')
  end

  def destroy
    clear_all_sessions current_user.id
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

  def auth_hash
    @auth_hash ||= request.env["omniauth.auth"]
  end

  def save_signup_history(member_id)
    SignupHistory.create(
      member_id: member_id,
      ip: request.ip,
      accept_language: request.headers["Accept-Language"],
      ua: request.headers["User-Agent"]
    )
  end

  def redirect_on_successful_sign_in
    "#{params[:provider].to_s.upcase}_OAUTH2_REDIRECT_URL".tap do |key|
      if ENV[key]
        redirect_to ENV[key]
      else
        redirect_back_or_settings_page
      end
    end
  end

  def redirect_on_unsuccessful_sign_in
    redirect_to signin_path, alert: t('.error')
  end
end
