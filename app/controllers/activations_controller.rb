class ActivationsController < ApplicationController
  include Concerns::TokenManagement

  before_action :token_required!, only: :edit

  def new
    raise if current_user.activated?

    activation = current_user.send_activation

    if activation.valid?
      flash[:notice] = t('.notice')
    else
      flash[:alert] = activation.errors.full_messages.join
    end

    redirect_to settings_path
  end

  def edit
    if @token.save
      if current_user
        redirect_to settings_path, notice: t('.notice')
      else
        redirect_to signin_path, notice: t('.notice')
      end
    end
  end
end
