module Admin
  module Withdraws
    class DuffsController < CoinsController
      load_and_authorize_resource class: '::Withdraws::Duff'
    end
  end
end
