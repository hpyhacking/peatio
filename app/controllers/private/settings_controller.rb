module Private
  class SettingsController < BaseController
    def index
      if current_user.email_unverified
        flash.now[:info] = t('.email_activated')
      elsif current_user.phone_unverified
        flash.now[:info] = t('.phone_number_activated')
      end
    end
  end
end

