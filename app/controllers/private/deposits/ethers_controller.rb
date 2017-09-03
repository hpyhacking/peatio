module Private
  module Deposits
    class EthersController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
