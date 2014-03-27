module Private
  class FundSourcesController < BaseController
    respond_to :json
    def index
       respond_with current_user.fund_sources.with_category(params[:currency])
    end

    def destroy
      FundSource.where(
        :id => params[:id],
        :is_locked => false,
        :account_id => current_user.accounts).destroy_all
      head :ok
    end
  end
end

