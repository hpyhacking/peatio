module Private
  module Deposits
    class BonpekaosController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
