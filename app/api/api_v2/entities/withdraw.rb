# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Withdraw < Base
      expose :id
      expose :currency_id, as: :currency
      expose(:type) { |w| w.fiat? ? :fiat : :coin }
      expose :sum, as: :amount
      expose :fee
      expose :txid, as: :blockchain_txid
      expose :rid
      expose :aasm_state, as: :state
      expose :confirmations, if: ->(withdraw) { withdraw.coin? }
      expose :created_at, :updated_at, :completed_at, format_with: :iso8601
      expose :completed_at, as: :done_at, format_with: :iso8601
    end
  end
end
