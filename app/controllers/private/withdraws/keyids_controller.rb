module Private
  module Withdraws
    class KeyidsController < ::Private::Withdraws::BaseController
      include ::Withdraws::CtrlCoinable
    end
  end
end
