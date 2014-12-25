class TwoFactorsController < ApplicationController
  before_action :auth_member!
  before_action :two_factor_required!

  def show
    respond_to do |format|
      if require_send_sms_verify_code?
        send_sms_verify_code
        format.any { render status: :ok, nothing: true }
      elsif two_factor_failed_locked?
        format.any { render status: :locked, inline: "<%= show_simple_captcha %>" }
      else
        format.any { render status: :ok, nothing: true }
      end
    end
  end

  def index
  end

  def update
    if two_factor_auth_verified?
      unlock_two_factor!

      redirect_to session.delete(:return_to) || settings_path
    else
      redirect_to two_factors_path, alert: t('.alert')
    end
  end

  private

  def two_factor_required!
    @two_factor ||= two_factor_by_type || first_available_two_factor

    if @two_factor.nil?
      redirect_to settings_path, alert: t('two_factors.auth.please_active_two_factor')
    end
  end

  def two_factor_by_type
    current_user.two_factors.activated.by_type(params[:id])
  end

  def first_available_two_factor
    current_user.two_factors.activated.first
  end

  def require_send_sms_verify_code?
    @two_factor.is_a?(TwoFactor::Sms) && params[:refresh]
  end

  def send_sms_verify_code
    @two_factor.refresh!
    @two_factor.send_otp
  end
end
