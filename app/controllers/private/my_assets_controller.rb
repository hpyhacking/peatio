module Private
  class MyAssetsController < BaseController
    def index
      @accounts = current_user.accounts
      load_transactions
      gon.jbuilder
    end

    private

    def load_transactions
      @deposits = Deposit.where(member: current_user)
      @withdraws = Withdraw.where(member: current_user).includes(:account)
      @buys = Trade.where(bid_member_id: current_user.id)
      @sells = Trade.where(ask_member_id: current_user.id)
    end
  end
end
