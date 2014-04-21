module Private
  class SettingsController < BaseController
    def index
      unless current_user.activated?
        flash.now[:info] = t('.activated')
      end

      @two_factor = current_user.two_factors.activated?
      @verified = (current_user.id_document and current_user.id_document_verified?)
    end
  end
end

