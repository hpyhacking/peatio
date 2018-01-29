module APIv2
  module Entities
    class WithdrawAddress < Base
      expose :id
      expose(:currency) { |w| w.currency.upcase }
      expose :extra, as: :label
      expose :uid, as: :address
    end
  end
end
