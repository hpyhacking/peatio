module Private
  module Deposits
    class LitecoinsController < BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
