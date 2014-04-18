module Private::Withdraws
  class ProtosharesController < ::Private::Withdraws::BaseController
    include ::Withdraws::CtrlCoinable
  end
end
