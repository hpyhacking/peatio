module Admin
  class MembersController < BaseController
    load_and_authorize_resource

    def index
      @search_field = params[:search_field]
      @search_term = params[:search_term]
      @members = Member.search(field: @search_field, term: @search_term).page params[:page]
    end

    def show
      @account_versions = AccountVersion.where(account_id: @member.account_ids).order(:id).reverse_order.page params[:page]
    end

    def toggle
      if params[:api]
        @member.api_disabled = !@member.api_disabled?
      else
        @member.disabled = !@member.disabled?
      end
      @member.save
    end

    def active
      @member.update_attribute(:activated, true)
      @member.save
      redirect_to admin_member_path(@member)
    end

  end
end
