module Private
  class TradeStatesController < BaseController
    def show
      @member = current_user
      @ask_account = @member.get_account params[:ask]
      @bid_account = @member.get_account params[:bid]
    end
  end
end
