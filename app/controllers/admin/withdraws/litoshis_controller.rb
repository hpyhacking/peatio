module Admin
  module Withdraws
    class LitoshisController < CoinsController
      load_and_authorize_resource class: '::Withdraws::Litoshi'
    end
  end
end
