module Private
  module Deposits
    class BitcoinCashController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
