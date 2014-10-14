class TwoFactorsController < ApplicationController
  before_action :auth_member!
  before_action :two_factor_required!

  def show
    respond_to do |format|
      if params[:refresh]
        @two_factor.refresh!
        @two_factor.send_otp
      end

      format.any { render status: :ok, text: {} }
    end
  end

  def index
  end

  def update
    if two_factor_auth_verified?
      redirect_to session.delete(:return_to) || settings_path
    else
      redirect_to two_factors_path, alert: t('.alert')
    end
  end

  private

  def two_factor_required!
    @two_factor ||= two_factor_by_type || first_availabel_two_factor
    redirect_to settings_path if @two_factor.nil?
  end

  def two_factor_by_type
    current_user.two_factors.by_type(params[:id])
  end

  def first_availabel_two_factor
    current_user.two_factors.activated.first
  end
end
