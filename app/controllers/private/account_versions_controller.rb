module Private
  class AccountVersionsController < BaseController
    def index
      @account_versions_grid = AccountVersionsGrid.new(params[:account_versions_grid]) do |scope|
        scope.where(:member_id => current_user.id)
      end
      @assets = @account_versions_grid.assets.page(params[:page]).per(20)
    end
  end
end
