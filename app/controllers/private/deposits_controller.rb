module Private
  class DepositsController < BaseController
    before_action :auth_activated!
    before_action :auth_verified!

    def index
      @deposits = DepositChannel.all.sort
    end

  end
end
