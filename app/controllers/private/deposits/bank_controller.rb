module Private
  module Deposits
    class BankController < BaseController
      def new
        @deposit = DepositChannelBank.get
      end

      def create
      end
    end
  end
end
