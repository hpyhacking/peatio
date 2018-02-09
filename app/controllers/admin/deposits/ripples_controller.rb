module Admin
  module Deposits
    class RipplesController < CoinsController
      load_and_authorize_resource class: '::Deposits::Ripple'
    end
  end
end
