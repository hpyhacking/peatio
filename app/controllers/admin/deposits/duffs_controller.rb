module Admin
  module Deposits
    class DuffsController < CoinsController
      load_and_authorize_resource class: '::Deposits::Duff'
    end
  end
end
