module Private
  module Deposits
    class BanksController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlBankable
    end
  end
end
