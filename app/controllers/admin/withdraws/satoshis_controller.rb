module Admin
  module Withdraws
    class SatoshisController < CoinsController
      load_and_authorize_resource class: '::Withdraws::Satoshi'
    end
  end
end
