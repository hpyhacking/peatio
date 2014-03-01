class SessionsController < ApplicationController

  before_filter :auth_anybody!, :only => [:new, :create, :failure]
  before_filter :auth_member!, :only => :destroy

  def new
    @identity = Identity.new
  end

  def create
    session.delete :active_code

    @identity = Identity.find(env["omniauth.auth"].uid)

    if @identity.too_many_failed_login_attempts
      flash[:alert] = t('sessions.failure.account_locked')
      render :new and return
    end

    if @identity.has_active_two_factor_auth?
      session[:tmp_identity_id] = @identity.id
      redirect_to two_factor_auth_path and return
    else
      Member.from_auth(env["omniauth.auth"])
      auth_success
    end
  end

  def new_with_two_factor_auth
    @identity = new
  end

  def create_with_two_factor_auth
    tmp_identity_id = session[:tmp_identity_id]
    if tmp_identity_id.blank?
      flash[:alert] = t('.session_expired')
      redirect_to signin_path and return
    end

    @identity = Identity.find(tmp_identity_id)

    unless @identity.verify_otp(params['identity']['otp'])
      @identity.errors.add(:otp, :invalid)
      return render :new_with_two_factor_auth
    end

    session.delete :tmp_identity_id
    auth_success
  end

  def failure
    @identity = Identity.where(email: params[:auth_key]).first
    if @identity.present?
      @identity.increment_retry_count
      @identity.save
      flash.now[:alert] = t('.account_locked') if @identity.too_many_failed_login_attempts
    else
      @identity = Identity.new
    end

    flash.now[:alert] = t('.error')
    render :new
  end

  def destroy
    reset_session
    redirect_to root_path
  end

  private

  def auth_success
    @identity.update_attributes(last_verify_at: Time.now, retry_count: 0)
    session[:identity_id] = @identity.id
    redirect_to new_activation_path
  end
end
