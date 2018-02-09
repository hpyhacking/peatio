module Admin
  module Withdraws
    class RipplesController < CoinsController
      load_and_authorize_resource class: '::Withdraws::Ripple'
    end
  end
end
