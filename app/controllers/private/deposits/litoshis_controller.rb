module Private
  module Deposits
    class LitoshisController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
