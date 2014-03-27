module Private
  module Deposits
    class BanksController < BaseController
      def new
        @deposit = DepositChannelBank.get
      end

      def create
      end
    end
  end
end
