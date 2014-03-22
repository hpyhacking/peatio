module Private
  module Deposits
    class CoinsController < BaseController
      def show
        @deposit = DepositChannel.find(params[:id])
        @account = current_user.ac(@deposit.currency)
        @address = @account.payment_address
      end
    end
  end
end
