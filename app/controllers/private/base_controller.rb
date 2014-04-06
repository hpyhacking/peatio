module Private
  class BaseController < ::ApplicationController
    before_filter :auth_member!

    private

    def verify_two_factor!
      return true unless current_user.two_factor_activated?

      two_factor = current_user.two_factor
      unless two_factor.verify(params[:two_factor][:otp])
        flash[:notice] = two_factor.errors[:otp].join
        redirect_to :back
      end
    end
  end
end
