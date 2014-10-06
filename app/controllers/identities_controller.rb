class IdentitiesController < ApplicationController
  before_filter :auth_anybody!, only: :new

  def new
    @identity = env['omniauth.identity'] || Identity.new
  end

  def edit
    @identity = current_user.identity
  end

  def update
    @identity = current_user.identity

    unless @identity.authenticate(params[:identity][:old_password])
      redirect_to edit_identity_path, alert: t('.auth-error') and return
    end

    if @identity.authenticate(params[:identity][:password])
      redirect_to edit_identity_path, alert: t('.auth-same') and return
    end

    if @identity.update_attributes(identity_params)
      current_user.send_password_changed_notification
      clear_all_sessions current_user.id
      reset_session
      redirect_to signin_path, notice: t('.notice')
    else
      render :edit
    end
  end

  private
  def identity_params
    params.required(:identity).permit(:password, :password_confirmation)
  end
end
