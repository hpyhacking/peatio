module Private
  module Deposits
    class DuffsController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
