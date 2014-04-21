module Private
  class TwoFactorsController < BaseController
    before_filter :fetch
    before_filter :activated!, only: [:edit, :destroy]
    before_filter :not_activated!, only: [:new, :create]

    def new
      @two_factor.refresh unless @two_factor.activated?
    end

    def edit
    end

    def create
      if @two_factor.verify
        @two_factor.update_attribute(:activated, true)
        redirect_to settings_path, notice: t('.notice')
      else
        flash.now[:alert] = t('.alert')
        render :new
      end
    end

    def destroy
      if @two_factor.verify
        @two_factor.update_attribute(:activated, false)
        redirect_to settings_path, notice: t('.notice')
      else
        flash.now[:alert] = t('.alert')
        render :edit
      end
    end

    private

    def fetch
      @two_factor = current_user.two_factor || current_user.create_two_factor
      if action_name == 'destroy' or action_name == 'create'
        @two_factor.assign_attributes(two_factor_params)
      end
    end

    def two_factor_params
      params.require(:two_factor).permit(:otp)
    end

    def activated!
      redirect_to settings_path unless current_user.two_factor_activated?
    end

    def not_activated!
      redirect_to settings_path if current_user.two_factor_activated?
    end
  end
end
