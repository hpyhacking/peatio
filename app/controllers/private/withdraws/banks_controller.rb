module Private::Withdraws
  class BanksController < ::Private::Withdraws::BaseController
    include ::Withdraws::CtrlBankable
  end
end
