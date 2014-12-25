module Verify
  class GoogleAuthsController < ApplicationController
    before_action :auth_member!
    before_action :find_google_auth
    before_action :google_auth_activated?,   only: [:show, :create]
    before_action :google_auth_inactivated?, only: [:edit, :destroy]
    before_action :two_factor_required!,     only: [:show]

    def show
      @google_auth.refresh! if params[:refresh]
    end

    def edit
    end

    def update
      if one_time_password_verified?
        @google_auth.active! and unlock_two_factor!
        redirect_to settings_path, notice: t('.notice')
      else
        redirect_to verify_google_auth_path, alert: t('.alert')
      end
    end

    def destroy
      if two_factor_auth_verified?
        @google_auth.deactive!
        redirect_to settings_path, notice: t('.notice')
      else
        redirect_to edit_verify_google_auth_path, alert: t('.alert')
      end
    end

    private

    def find_google_auth
      @google_auth ||= current_user.app_two_factor
    end

    def google_auth_params
      params.require(:google_auth).permit(:otp)
    end

    def one_time_password_verified?
      @google_auth.assign_attributes(google_auth_params)
      @google_auth.verify?
    end

    def google_auth_activated?
      redirect_to settings_path, notice: t('.notice.already_activated') if @google_auth.activated?
    end

    def google_auth_inactivated?
      redirect_to settings_path, notice: t('.notice.not_activated_yet') if not @google_auth.activated?
    end

    def two_factor_required!
      return if not current_user.sms_two_factor.activated?

      if two_factor_locked?
        session[:return_to] = request.original_url
        redirect_to two_factors_path
      end
    end

  end
end
