module Admin
  class BaseController < ::ApplicationController
    layout 'admin'

    before_filter :auth_member!
    before_filter :auth_active!
    before_filter :auth_admin!

    load_and_authorize_resource

    def current_ability
      @current_ability ||= Admin::Ability.new(current_user)
    end
  end
end

