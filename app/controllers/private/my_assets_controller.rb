module Private
  class MyAssetsController < BaseController
    def index
      @accounts = current_user.accounts
      load_transactions
      gon.jbuilder controller: self
    end

    private

    def load_transactions
      @market = Market.find(latest_market)
      @deposits = Deposit.where(member: current_user).with_aasm_state(:accepted)
      @withdraws = Withdraw.where(member: current_user).with_aasm_state(:done)
      @buys = Trade.where(bid_member_id: current_user.id)
      @sells = Trade.where(ask_member_id: current_user.id)
    end
  end
end
