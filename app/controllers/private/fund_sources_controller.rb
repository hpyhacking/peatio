module Private
  class FundSourcesController < BaseController
    respond_to :json
    def index
      respond_with current_user.fund_sources.with_channel(params[:channel_id])
    end

    def destroy
      FundSource.where(
        member: current_user,
        id: params[:id],
        is_locked: false).destroy_all
      head :ok
    end
  end
end

