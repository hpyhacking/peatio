module Private
  module Deposits
    class SatoshisController < BaseController
      include ::DepositCtrlCoinable
    end
  end
end
