module Private
  class DepositsController < BaseController
    def index
      @depostis = DepositChannel.all
    end
  end
end
