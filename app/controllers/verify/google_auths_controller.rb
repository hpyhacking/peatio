module Verify
  class GoogleAuthsController < ApplicationController
    before_action :auth_member!
    before_action :find_google_auth
    before_action :google_auth_activated?,   only: [:show, :create]
    before_action :google_auth_inactivated?, only: [:edit, :destroy]
    before_action :verify_sms_two_factor,    only: [:update]

    def show
      @google_auth.refresh if params[:refresh]
      @google_auth.refresh if @google_auth.otp_secret.blank?
    end

    def edit
    end

    def update
      if one_time_password_verified?
        @google_auth.active!
        redirect_to settings_path, notice: t('.notice')
      else
        redirect_to verify_google_auth_path, alert: t('.alert')
      end
    end

    def destroy
      if one_time_password_verified?
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
      @google_auth.verify
    end

    def google_auth_activated?
      redirect_to settings_path, notice: t('.already_activated') if @google_auth.activated?
    end

    def google_auth_inactivated?
      redirect_to settings_path, notice: t('.not_activated_yet') if not @google_auth.activated?
    end

    def verify_sms_two_factor
      if current_user.sms_two_factor.activated? and !two_factor_auth_verified?
        redirect_to verify_google_auth_path, alert: t('.sms_two_factor_error')
      end
    end
  end
end
