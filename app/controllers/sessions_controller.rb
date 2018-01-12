class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  before_action :auth_member!, only: :destroy
  before_action :auth_anybody!, only: %i[ new failure ]

  def new
    @identity = Identity.new
  end

  def create
    @member = Member.from_auth(auth_hash)

    if @member
      if @member.disabled?
        redirect_to signin_path, alert: t('.disabled')
      else
        reset_session rescue nil
        session[:member_id] = @member.id
        save_session_key @member.id, cookies['_peatio_session']
        MemberMailer.notify_signin(@member.id).deliver if @member.activated?
        redirect_on_successful_sign_in
      end
    else
      redirect_on_unsuccessful_sign_in
    end
  end

  def failure
    redirect_to signin_path, alert: t('.error')
  end

  def destroy
    clear_all_sessions current_user.id
    reset_session
    redirect_to root_path
  end

  private

  def auth_hash
    @auth_hash ||= request.env['omniauth.auth']
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
