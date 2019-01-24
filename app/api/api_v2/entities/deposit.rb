# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Deposit < Base
      expose(
        :id,
        documentation: {
          type: Integer,
          desc: 'Unique deposit id.'
        }
      )

      expose(
        :currency_id,
        as: :currency,
        documentation: {
          type: String,
          desc: 'Deposit currency id.'
        }
      )

      expose(
        :amount,
        format_with: :decimal,
        documentation: {
          type: BigDecimal,
          desc: 'Deposit amount.'
        }
      )

      expose(
        :fee,
        documentation: {
          type: BigDecimal,
          desc: 'Deposit fee.'
        }
      )

      expose(
        :txid,
        documentation: {
          type: String,
          desc: 'Deposit transaction id.'
        }
      )

      expose(
        :confirmations,
        documentation: {
          type: Integer,
          desc: 'Number of deposit confirmations.'
        },
        if: ->(deposit) { deposit.coin? }
      )

      expose(
        :aasm_state,
        as: :state,
        documentation: {
          type: String,
          desc: 'Deposit state.'
        }
      )

      expose(
        :created_at,
        format_with: :iso8601,
        documentation: {
          type: String,
          desc: 'The datetime when deposit was created.'
        }
      )

      expose(
        :completed_at,
        format_with: :iso8601,
        documentation: {
          type: String,
          desc: 'The datetime when deposit was completed..'
        }
      )
    end
  end
end
