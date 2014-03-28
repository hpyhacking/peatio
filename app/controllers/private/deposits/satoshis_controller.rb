module Private
  module Deposits
    class SatoshisController < BaseController
      include ::ControllerDepositCoinable
      def currency
        'btc'
      end
    end
  end
end
