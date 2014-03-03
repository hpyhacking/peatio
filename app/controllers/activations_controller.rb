class ActivationsController < ApplicationController
  include Concerns::TokenManagement

  before_action :auth_member!, only: :update
  before_action :token_required!, only: :edit

  def new
    raise if current_user.activated?

    activation = Activation.new(member: current_user)

    if activation.save
      flash[:notice] = t('.notice')
    else
      flash[:alert] = activation.errors.full_messages
    end

    redirect_to settings_path
  end

  def edit
    if @token.save
      redirect_to settings_path, notice: t('.notice')
    end
  end
end
