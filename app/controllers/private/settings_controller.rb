module Private
  class SettingsController < BaseController
    def index
      unless current_user.activated?
        flash.now[:info] = t('.activated')
      end

      @accounts    = current_user.accounts
      @two_factor  = current_user.two_factors.by_type(:app).activated?
    end
  end
end

