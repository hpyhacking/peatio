module Private
  module Deposits
    class SatoshiController < BaseController
      def new
        @channel = DepositChannelSatoshi.get
        @currency = @channel.currency
        redirect_to root_path unless Currency.coins.keys.include?(@currency)

        @account = current_user.get_account(@currency)
        @account.gen_payment_address if @account.payment_addresses.empty?
        @address = @account.payment_addresses.using
      end

      def create
      end
    end
  end
end
