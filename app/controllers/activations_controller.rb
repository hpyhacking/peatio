class ActivationsController < ApplicationController
  include Concerns::TokenManagement

  before_action :token_required!, only: :edit

  def new
    if current_user.activated?
      redirect_to settings_path and return
    end

    activation = current_user.send_activation

    if not activation.valid?
      flash[:alert] = activation.errors.full_messages.join
    end

    redirect_to settings_path
  end

  def edit
    @token.confirmed

    if current_user
      redirect_to settings_path, notice: t('.notice')
    else
      redirect_to signin_path, notice: t('.notice')
    end
  end
end
