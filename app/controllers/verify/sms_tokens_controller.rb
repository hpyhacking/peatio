module Verify
  class SmsTokensController < ApplicationController
    before_action :auth_member!
    before_action :activated?

    def new
    end

    def create
      @token = Token::SmsToken.for_member(current_user)

      if params[:commit] == 'send_code'
        send_code_phase
      else
        verify_code_phase
      end
    end

    private

    def activated?
      if current_user.two_factors.by_type(:sms).activated?
        redirect_to settings_path
      end
    end

    def send_code_phase
      @token.assign_attributes token_params

      respond_to do |format|
        if @token.phone_number.present? && @token.valid?
          @token.update_phone_number
          @token.send_verify_code

          text = I18n.t('verify.sms_tokens.new.notice.send_code_success')
          format.any { render status: :ok, text: {text: text}.to_json }
        else
          text = @token.errors.full_messages.to_sentence
          format.any { render status: :bad_request, text: {text: text}.to_json }
        end
      end
    end

    def verify_code_phase
      @token.assign_attributes token_params

      respond_to do |format|
        if @token.verify_code.present? && @token.verify?
          @token.verified!
          current_user.two_factors.by_type(:sms).active!

          MemberMailer.phone_number_verified(current_user.id).deliver

          text = I18n.t('verify.sms_tokens.new.notice.verify_code_success')
          flash[:notice] = text
          format.any { render status: :ok, text: {text: text, reload: true}.to_json }
        else
          text = @token.errors.full_messages.to_sentence
          format.any { render status: :bad_request, text: {text: text}.to_json }
        end
      end
    end

    def token_params
      params.required(:token_sms_token).permit(:phone_number, :verify_code)
    end
  end
end
