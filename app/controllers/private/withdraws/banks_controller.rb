module Private::Withdraws
  class BanksController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
