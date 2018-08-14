# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Deposit < Base
      expose :id, documentation: 'Unique deposit id.'
      expose :currency_id, as: :currency
      expose :amount, format_with: :decimal
      expose :fee
      expose :txid
      expose :created_at, format_with: :iso8601
      expose :confirmations, if: ->(deposit) { deposit.coin? }
      expose :completed_at, format_with: :iso8601
      expose :aasm_state, as: :state
    end
  end
end
