module Private
  class FundsController < BaseController
    layout 'app'

    before_action :auth_activated!
    before_action :auth_verified!

    def index
      @deposit_channels = DepositChannel.all
      @withdraw_channels = WithdrawChannel.all
      @currencies = (DepositChannel.all(&:currency_obj) + WithdrawChannel.all(&:currency_obj)).uniq
      @deposits = current_user.deposits
      @accounts = current_user.accounts
    end
  end
end

