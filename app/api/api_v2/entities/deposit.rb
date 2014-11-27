module APIv2
  module Entities
    class Deposit < Base
      expose :currency
      expose :amount
      expose :fee
      expose :txid
      expose :created_at
      expose :memo
      expose :done_at
    end
  end
end