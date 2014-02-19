module Private
  class OtpsController < BaseController
    before_filter :is_otp!, :only => :destroy
    before_filter :not_otp!, :only => :create
    before_filter :verify_otp!, :only => [:show, :edit, :update]

    def new
      @two_factor = current_identity.two_factor || current_identity.create_two_factor
      @two_factor.refresh

      render :new
    end

    def create
      @two_factor = current_identity.two_factor
      @two_factor.assign_attributes(otp_params)

      if @two_factor.verify()
        flash[:notice] = t('private.settings.success')
        redirect_to settings_path
      else
        flash[:alert] = t('private.settings.failure')
        redirect_to new_otp_path
      end
    end

    def destroy
      if current_identity.authenticate(params[:password])
        current_identity.two_factor.update_attribute(:is_active, false)
        flash[:notice] = t('private.settings.success')
      else
        flash[:alert] = t('invalid_password')
      end
      redirect_to settings_path
    end

    private

    def otp_params
      params.require(:otp).permit(:otp)
    end

    def is_otp!
      raise '2-step authentication is not activated' unless current_identity.two_factor.is_active
    end

    def not_otp!
      raise '2-setp authentication is already activated' if current_identity.two_factor.is_active
    end
  end
end

