module APIv2
  module Entities
    class Account < Base
      expose :currency
      expose :balance, format_with: :decimal
      expose :locked,  format_with: :decimal
    end
  end
end
