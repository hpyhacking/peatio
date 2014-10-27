module Private
  class WithdrawsController < BaseController
    before_action :auth_activated!
    before_action :auth_verified!

    def index
      @channels = WithdrawChannel.all
    end

  end
end
