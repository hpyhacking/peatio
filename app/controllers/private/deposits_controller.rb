module Private
  class DepositsController < BaseController
    layout 'app'

    before_action :auth_activated!
    before_action :auth_verified!

    def index
      @deposit_channels = DepositChannel.all.sort
      @deposits = current_user.deposits
      @accounts = current_user.accounts
    end

  end
end
