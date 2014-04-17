module Verify
  class SmsTokensController < ApplicationController
    before_action :auth_member!
    before_action :phone_number_verified
    before_action :remove_exists_token, only: [:new]

    def new
    end

    def create

    end

    private

    def phone_number_verified
      if current_user.phone_number_verified?
        redirect_to settings_path
      end
    end

    def remove_exists_token
    end

  end
end
