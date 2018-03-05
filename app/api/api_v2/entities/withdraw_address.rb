module APIv2
  module Entities
    class WithdrawAddress < Base
      expose :id
      expose(:currency) { |w| w.currency.code }
      expose :extra, as: :label
      expose :uid, as: :address
    end
  end
end
