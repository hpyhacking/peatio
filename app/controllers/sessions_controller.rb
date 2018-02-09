class SessionsController < ApplicationController
  before_action :auth_member!, only: :destroy
  before_action :auth_anybody!, only: :failure

  def create
    @member = Member.from_auth(auth_hash)

    return redirect_on_unsuccessful_sign_in unless @member
    return redirect_to(root_path, alert: t('.disabled')) if @member.disabled?

    reset_session rescue nil
    session[:member_id] = @member.id
    save_session_key @member.id, cookies['_peatio_session']
    redirect_on_successful_sign_in
  end

  def failure
    redirect_to root_path, alert: t('.error')
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
    "#{params[:provider].to_s.gsub(/(?:_|oauth2)+\z/i, '').upcase}_OAUTH2_REDIRECT_URL".tap do |key|
      if ENV[key] && params[:provider].to_s == 'barong'
        auth_data = auth_hash['credentials']
        auth_data['full_name'] = @member.full_name
        redirect_to "#{ENV[key]}?#{auth_data.to_query}"
      elsif ENV[key]
        redirect_to ENV[key]
      else
        redirect_back_or_settings_page
      end
    end
  end

  def redirect_on_unsuccessful_sign_in
    redirect_to root_path, alert: t('.error')
  end
end
