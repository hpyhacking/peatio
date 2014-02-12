module Private
  class SettingsController < BaseController
    def index
      two_factor = current_identity.two_factor
      @two_factor_auth_enabled =  two_factor && two_factor.is_active
    end
  end
end

