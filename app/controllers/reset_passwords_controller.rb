class ResetPasswordsController < ApplicationController
  include Concerns::TokenManagement

  before_action :auth_anybody!
  before_action :token_required, :only => [:edit, :update]

  def new
    @reset_password = Token::ResetPassword.new
  end

  def create
    @reset_password = Token::ResetPassword.new(reset_password_params)

    if @reset_password.save
      clear_all_sessions @reset_password.member_id
      redirect_to signin_path, notice: t('.success')
    else
      redirect_to url_for(action: :new), alert: @reset_password.errors.full_messages.join(', ')
    end
  end

  def edit
  end

  def update
    if @token.update_attributes(reset_password_update_params)
      @token.confirmed
      @token.member.send_password_changed_notification
      redirect_to signin_path, notice: t('.success')
    else
      render :edit
    end
  end

  private
  def reset_password_params
    params.required(:token_reset_password).permit(:email)
  end

  def reset_password_update_params
    params.required(:token_reset_password).permit(:password)
  end
end
