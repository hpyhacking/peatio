module Private
  module Deposits
    class ProtosharesController < ::Private::Deposits::BaseController
      include ::DepositCtrlCoinable
    end
  end
end
