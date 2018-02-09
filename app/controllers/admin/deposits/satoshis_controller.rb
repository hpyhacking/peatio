module Admin
  module Deposits
    class SatoshisController < CoinsController
      load_and_authorize_resource class: '::Deposits::Satoshi'
    end
  end
end
