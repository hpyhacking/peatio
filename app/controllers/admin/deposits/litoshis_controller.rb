module Admin
  module Deposits
    class LitoshisController < CoinsController
      load_and_authorize_resource class: '::Deposits::Litoshi'
    end
  end
end
