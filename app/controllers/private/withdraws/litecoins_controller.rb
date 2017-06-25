module Private::Withdraws
  class LitecoinsController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
