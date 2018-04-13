module APIv2
  module Entities
    class Deposit < Base
      expose :id, documentation: "Unique deposit id."
      expose(:currency) { |deposit| deposit.currency.code }
      expose :amount, format_with: :decimal
      expose :fee
      expose :txid
      expose :created_at, format_with: :iso8601
      expose :confirmations
      expose :completed_at, format_with: :iso8601
      expose :aasm_state, as: :state
    end
  end
end
