module Authentications
  class IdentitiesController < ApplicationController
    before_action :auth_member!

    def new
      @identity = Identity.new(email: current_user.email)
    end

    def create
      identity = Identity.new(identity_params.merge(email: current_user.email))
      if identity.save && current_user.create_auth_for_identity(identity)
        redirect_to settings_path, notice: t('.success')
      else
        redirect_to new_authentications_identity_path, alert: identity.errors.full_messages.join(',')
      end
    end

    private

    def identity_params
      params.required(:identity).permit(:password, :password_confirmation)
    end

  end
end
