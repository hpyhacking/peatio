module Private
  class FundsController < BaseController
    layout 'app'

    before_action :auth_activated!
    before_action :auth_verified!

    def index
      @deposit_channels = DepositChannel.all
      @withdraw_channels = WithdrawChannel.all
      @currencies = Currency.all
      @deposits = current_user.deposits
      @accounts = current_user.accounts
      @withdraws = current_user.withdraws
      @fund_sources = current_user.fund_sources
    end
  end
end

