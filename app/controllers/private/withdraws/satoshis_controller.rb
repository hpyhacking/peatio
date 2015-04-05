module Private::Withdraws
  class SatoshisController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
