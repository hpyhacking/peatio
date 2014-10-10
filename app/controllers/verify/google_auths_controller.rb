module Verify
  class GoogleAuthsController < ApplicationController
    before_action :auth_member!
    before_action :find_google_auth
    before_action :activated!, only: [:edit, :destroy]
    before_action :not_activated!, only: [:show, :create]

    def show
      @google_auth.refresh if params[:refresh]
      @google_auth.refresh if @google_auth.otp_secret.blank?
    end

    def edit
    end

    def update
      if google_auth_verified?
        @google_auth.active!
        MemberMailer.google_auth_activated(current_user.id).deliver
        redirect_to settings_path, notice: t('.notice')
      else
        flash[:alert] = t('.alert')
        redirect_to verify_google_auth_path(:app)
      end
    end

    def destroy
      if google_auth_verified?
        @google_auth.deactive!
        MemberMailer.google_auth_deactivated(current_user.id).deliver
        redirect_to settings_path, notice: t('.notice')
      else
        flash[:alert] = t('.alert')
        redirect_to edit_verify_google_auth_path(:app)
      end
    end

    private

    def find_google_auth
      @google_auth = current_user.app_two_factor
    end

    def google_auth_params
      params.require(:google_auth).permit(:otp)
    end

    def google_auth_verified?
      @google_auth.assign_attributes(google_auth_params)
      @google_auth.verify
    end

    def activated!
      redirect_to settings_path if not @google_auth.activated?
    end

    def not_activated!
      redirect_to settings_path if @google_auth.activated?
    end
  end
end
