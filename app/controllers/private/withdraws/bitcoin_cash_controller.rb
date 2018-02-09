module Private::Withdraws
  class BitcoinCashController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
