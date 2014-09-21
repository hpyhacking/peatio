module Private
  class WithdrawsController < BaseController
    before_action :auth_activated!
    before_action :auth_verified!

    HIDDEN_CHANNEL = %w(btsx)
    def index
      @channels = WithdrawChannel.all.select{|c| !HIDDEN_CHANNEL.include?(c.currency)}.sort
    end

  end
end
