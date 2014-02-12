class ResetPasswordsController < ApplicationController
  include Concerns::TokenManagement

  layout 'dialog'
  before_filter :token_required, :only => [:edit, :update]

  def new
    @reset_pwd = ResetPassword.new
  end

  def create
    @reset_pwd = ResetPassword.new(reset_password_params)

    if verify_recaptcha(:model => @reset_pwd, :attribute => :captcha) \
      and @reset_pwd.save
      redirect_to root_path, :notice => t('.success')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if reset_password_success?
      redirect_to root_path, :notice => t('.success')
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

  def reset_password_success?
    @token.update_attributes(reset_password_update_params) && @token.identity.update_attributes(retry_count: 0)
  end
end

