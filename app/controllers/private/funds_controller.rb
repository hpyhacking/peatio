module Private
  class FundsController < BaseController
    layout 'app'

    before_action :auth_activated!
    before_action :auth_verified!

    def index
      @deposit_channels = DepositChannel.all
      @withdraw_channels = WithdrawChannel.all
      @currencies = (DepositChannel.all.map(&:currency_obj) + WithdrawChannel.all.map(&:currency_obj)).uniq
      @deposits = current_user.deposits
      @accounts = current_user.accounts
    end
  end
end

