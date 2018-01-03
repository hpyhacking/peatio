module Private
  module Deposits
    class RipplesController < ::Private::Deposits::BaseController
      include ::Deposits::CtrlCoinable
    end
  end
end
