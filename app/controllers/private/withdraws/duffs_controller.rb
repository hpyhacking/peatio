module Private::Withdraws
  class DuffsController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
