module Admin
  class BaseController < ::ApplicationController
    layout 'admin'

    before_action :auth_admin!
    before_action :auth_member!
    before_action :two_factor_required!

    def current_ability
      @current_ability ||= Admin::Ability.new(current_user)
    end

    def two_factor_required!
      if two_factor_locked?(expired_at: ENV['SESSION_EXPIRE'].to_i.minutes)
        session[:return_to] = request.original_url
        redirect_to two_factors_path
      end
    end
  end
end

