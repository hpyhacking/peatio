module Private
  class SettingsController < BaseController
    def index
      if current_user.email && !current_user.email_activated
        flash.now[:info] = t('.email_activated')
      elsif current_user.phone_number && !current_user.phone_number_activated
        flash.now[:info] = t('.phone_number_activated')
      end
    end
  end
end

