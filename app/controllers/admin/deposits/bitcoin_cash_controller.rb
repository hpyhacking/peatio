module Admin
  module Deposits
    class BitcoinCashController < CoinsController
      load_and_authorize_resource class: '::Deposits::BitcoinCash'
    end
  end
end
