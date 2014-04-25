module Admin
  class MembersController < BaseController
    load_and_authorize_resource
    def show
      @account_versions = AccountVersion.where(account_id: current_user.account_ids).order("id DESC").page params[:page]
    end

    def update
      raise unless MemberTag.tags.include? params[:tag]
      if @member.tag_list.include? params[:tag]
        @member.tag_list.remove params[:tag]
      else
        @member.tag_list.add params[:tag]
      end

      @member.save

      redirect_to admin_member_path(@member)
    end
  end
end
