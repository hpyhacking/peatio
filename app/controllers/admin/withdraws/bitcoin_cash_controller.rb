module Admin
  module Withdraws
    class BitcoinCashController < CoinsController
      load_and_authorize_resource class: '::Withdraws::BitcoinCash'
    end
  end
end
