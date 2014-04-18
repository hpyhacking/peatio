module Private
  module Deposits
    class SatoshisController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
