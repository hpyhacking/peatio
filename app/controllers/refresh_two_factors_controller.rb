class RefreshTwoFactorsController < ApplicationController
  before_action :find_member

  def show
    two_factor = @member.two_factors.by_type(params[:id])

    respond_to do |format|
      if two_factor
        two_factor.refresh
        two_factor.send_otp

        format.any { render status: :ok, text: {} }
      else
        format.any { render status: :bad_request, text: {}}
      end
    end
  end

  private

  def find_member
    @member ||= find_by_member_id || find_by_temp_member_id
  end

  def find_by_member_id
    Member.find_by_id(session[:member_id])
  end

  def find_by_temp_member_id
    Member.find_by_id(session[:temp_member_id])
  end
end
