module Private
  module Deposits
    class LitecoinsController < ::Private::Deposits::BaseController
      include ::DepositCtrlCoinable
    end
  end
end
