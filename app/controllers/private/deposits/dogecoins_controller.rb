module Private
  module Deposits
    class DogecoinsController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
