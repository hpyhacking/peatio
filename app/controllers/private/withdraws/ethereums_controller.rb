module Private::Withdraws
  class EthereumsController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
