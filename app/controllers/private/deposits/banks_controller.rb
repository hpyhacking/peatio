module Private
  module Deposits
    class BanksController < BaseController
      def new
        @deposit = DepositChannel.find('bank')
      end
    end
  end
end

