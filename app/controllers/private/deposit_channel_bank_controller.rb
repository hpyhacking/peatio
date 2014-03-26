module Private
  class DepositChannelBankController < BaseController
    before_action :auth_activated!

    def new
      @deposit = DepositChannelBank.get
    end

    def create
    end
  end
end
