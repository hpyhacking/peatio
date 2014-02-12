class ResetTwoFactorsController < ApplicationController
  include Concerns::TokenManagement

  layout 'dialog'
  before_filter :token_required, :only => :edit

  def new
    @reset_otp = ResetTwoFactor.new
  end

  def create
    @reset_otp = ResetTwoFactor.new(reset_otp_params)

    if verify_recaptcha(:model => @reset_otp, :attribute => :captcha) \
      and @reset_otp.save
      redirect_to root_path, :notice => t('.success')
    else
      render :new
    end
  end

  def edit
    if @token.save
      redirect_to signin_path, :notice => t('.success')
    end
  end

  private
  def reset_otp_params
    params.required(:reset_two_factor).permit(:email)
  end
end

