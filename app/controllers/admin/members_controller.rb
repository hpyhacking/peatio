module Admin
  class MembersController < BaseController
    def show
      @accounts = @member.accounts

      @account_versions_grid = AccountVersionsGrid.new(params[:account_versions_grid]) do |scope|
        scope.where(:member_id => @member.id)
      end
      @assets = @account_versions_grid.assets.page(params[:page]).per(20)
    end

    def update
      raise unless BaseConfig.member.tags.include? params[:tag]
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
