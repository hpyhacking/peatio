module Private
  module Deposits
    class KeyidsController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end

