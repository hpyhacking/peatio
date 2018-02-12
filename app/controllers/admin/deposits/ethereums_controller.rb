module Admin
  module Deposits
    class EthereumsController < CoinsController
      load_and_authorize_resource class: '::Deposits::Ethereum'
    end
  end
end
