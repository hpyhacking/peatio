# encoding: UTF-8
# frozen_string_literal: true

class SessionsController < ApplicationController
  before_action :auth_member!, only: :destroy
  before_action :auth_anybody!, only: :failure

  def create
    @member = Member.from_auth(auth_hash)

    return redirect_on_unsuccessful_sign_in unless @member
    return redirect_to(root_path, alert: t('.disabled')) if @member.disabled?

    reset_session rescue nil
    session[:member_id] = @member.id
    memoize_member_session_id @member.id, session.id
    redirect_on_successful_sign_in
  end

  def failure
    redirect_to root_path, alert: t('.error')
  end

  def destroy
    destroy_member_sessions(current_user.id)
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
        redirect_to "#{ENV[key]}?#{auth_hash.fetch('credentials').to_query}"
      elsif ENV[key]
        redirect_to ENV[key]
      else
        redirect_to settings_url
      end
    end
  end

  def redirect_on_unsuccessful_sign_in
    redirect_to root_path, alert: t('.error')
  end
end
