module APIv2
  module Entities
    class Deposit < Base
      expose :currency
      expose :amount, format_with: :decimal
      expose :fee
      expose :fund_uid
      expose :txid
      expose :created_at, format_with: :iso8601
      expose :memo
      expose :done_at, format_with: :iso8601
    end
  end
end