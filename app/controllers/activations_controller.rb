class ActivationsController < ApplicationController
  include Concerns::TokenManagement

  before_filter :auth_member!, only: [:new, :update]
  before_filter do
    redirect_to root_path if current_identity && current_identity.is_active?
  end
  before_filter :token_required, :only => :edit

  def new
    @activation = current_identity.activation
  end

  def edit
    if @token.save
      if current_identity
        redirect_to root_path
      else
        flash[:notice] = t('.success')
        redirect_to signin_path
      end
    end
  end

  def update
    activation = Activation.new identity: current_identity, email: current_identity.email
    unless activation.save
      flash[:error] = activation.errors.full_messages.join('; ')
    end
    redirect_to new_activation_path
  end
end
