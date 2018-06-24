module Private::Withdraws
  class BonpekaosController < ::Private::Withdraws::BaseController
    include ::Withdraws::Withdrawable
  end
end
