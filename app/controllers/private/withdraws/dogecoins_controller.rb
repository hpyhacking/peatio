module Private::Withdraws
  class DogecoinsController < ::Private::Withdraws::BaseController
    include ::Withdraws::CtrlCoinable
  end
end
