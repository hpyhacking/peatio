class ResetPasswordsController < ApplicationController
  include Concerns::TokenManagement
  before_filter :auth_anybody!
  before_filter :token_required, :only => [:edit, :update]

  def new
    @reset_password = ResetPassword.new
  end

  def create
    @reset_password = ResetPassword.new(reset_password_params)

    if @reset_password.save
      redirect_to signin_path, notice: t('.success')
    else
      redirect_to url_for(action: :new), alert: @reset_password.errors.full_messages.join(', ')
    end
  end

  def edit
  end

  def update
    if @token.update_attributes(reset_password_update_params)
      redirect_to signin_path, notice: t('.success')
    else
      render :edit
    end
  end

  private
  def reset_password_params
    params.required(:reset_password).permit(:email)
  end

  def reset_password_update_params
    params.required(:reset_password).permit(:password)
  end
end
