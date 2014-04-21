module Private
  class TwoFactorsController < BaseController
    before_action :fetch
    before_action :activated!, only: [:edit, :destroy]
    before_action :not_activated!, only: [:show, :create]

    def show
      @two_factor.refresh if params[:refresh]
    end

    def edit
    end

    def update
      if two_factor_verified?
        @two_factor.update_attribute(:activated, true)
        redirect_to settings_path, notice: t('.notice')
      else
        flash[:alert] = t('.alert')
        redirect_to two_factor_path(:app)
      end
    end

    def destroy
      if two_factor_verified?
        @two_factor.update_attribute(:activated, false)
        redirect_to settings_path, notice: t('.notice')
      else
        flash[:alert] = t('.alert')
        render edit_two_factor_path(:app)
      end
    end

    private

    def fetch
      @two_factor = current_user.two_factors.by_type(:app)
    end

    def two_factor_params
      params.require(:two_factor).permit(:otp)
    end

    def two_factor_verified?
      @two_factor.assign_attributes(two_factor_params)
      @two_factor.verify
    end

    def activated!
      redirect_to settings_path if not @two_factor.activated?
    end

    def not_activated!
      redirect_to settings_path if @two_factor.activated?
    end
  end
end
