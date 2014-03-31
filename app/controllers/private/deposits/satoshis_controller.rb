module Private
  module Deposits
    class SatoshisController < ::Private::Deposits::BaseController
      include ::DepositCtrlCoinable
    end
  end
end
