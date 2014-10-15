module Authentications
  class EmailsController < ApplicationController
    before_action :auth_member!
    before_action :check_email_present

    def new
      flash.now[:info] = t('.setup_email')
    end

    def create
      if current_user.update_attributes(email: params[:email][:address])
        redirect_to settings_path
      else
        flash.now[:alert] = current_user.errors.full_messages.join(',')
        render :new
      end
    end

    private
    def check_email_present
      redirect_to settings_path if current_user.email.present?
    end
  end

end
