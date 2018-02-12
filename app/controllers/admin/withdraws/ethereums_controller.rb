module Admin
  module Withdraws
    class EthereumsController < CoinsController
      load_and_authorize_resource class: '::Withdraws::Ethereum'
    end
  end
end