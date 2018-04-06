module APIv2
  module Entities
    class Withdraw < Base
      expose :id
      expose(:currency) { |w| w.currency.code }
      expose(:type) { |w| w.fiat? ? :fiat : :coin }
      expose :sum, as: :amount
      expose :fee
      expose :txid, as: :blockchain_txid
      expose :rid
      expose :aasm_state, as: :state
      expose :created_at, :updated_at, :done_at, format_with: :iso8601
    end
  end
end
