module Private
  module Deposits
    class EthereumsController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end