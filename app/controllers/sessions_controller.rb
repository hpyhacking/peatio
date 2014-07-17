class SessionsController < ApplicationController
  before_action :auth_member!, only: :destroy
  before_action :auth_anybody!, only: [:new, :create, :failure]

  def new
    @identity = Identity.new
  end

  def create
    @member = Member.from_auth(env["omniauth.auth"])

    if @member
      session[:temp_member_id] = @member.id
      redirect_to new_verify_two_factor_path
    else
      redirect_to signin_path, alert: t('.error') unless @member
    end
  end

  def failure
    redirect_to signin_path, alert: t('.error')
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end
