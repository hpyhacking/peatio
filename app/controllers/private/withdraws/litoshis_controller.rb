module Private::Withdraws
  class LitoshisController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
