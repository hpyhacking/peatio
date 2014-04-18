module Private
  module Deposits
    class ProtosharesController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
