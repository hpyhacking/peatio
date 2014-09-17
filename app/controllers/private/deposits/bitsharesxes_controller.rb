module Private
  module Deposits
    class BitsharesxesController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
