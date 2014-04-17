module Verify
  class PhoneNumbersController < ApplicationController
    before_action :auth_member!

    def new
      if current_user.phone_number_verified?
        redirect_to settings_path and return
      end

      @token = current_user.sms_token || current_user.create_sms_token
    end

    def create

    end

  end
end
