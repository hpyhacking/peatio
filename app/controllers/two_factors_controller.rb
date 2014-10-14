class TwoFactorsController < ApplicationController

  def show
    two_factor = current_user.two_factors.by_type(params[:id])

    respond_to do |format|
      if two_factor
        if params[:refresh]
          two_factor.refresh!
          two_factor.send_otp
        end

        format.any { render status: :ok, text: {} }
      else
        format.any { render status: :bad_request, text: {}}
      end
    end
  end

  def index
  end

  def update
  end
end
