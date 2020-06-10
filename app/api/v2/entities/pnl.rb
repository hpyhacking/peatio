# frozen_string_literal: true

module API
  module V2
    module Entities
      class Pnl < Base
        expose(
          :currency_id,
          as: :currency,
          documentation: {
            type: String,
            desc: 'Currency code.'
          }
        )

        expose(
          :pnl_currency_id,
          as: :pnl_currency,
          documentation: {
            type: String,
            desc: 'PnL currency code.'
          }
        )

        expose(
          :total_credit,
          documentation: {
            type: BigDecimal,
            desc: 'Total credit amount.'
          }
        )

        expose(
          :total_debit,
          documentation: {
            type: BigDecimal,
            desc: 'Total debit amount.'
          }
        )

        expose(
          :total_credit_value,
          documentation: {
            type: BigDecimal,
            desc: 'Total credit value in pnl currency.'
          }
        )

        expose(
          :total_debit_value,
          documentation: {
            type: BigDecimal,
            desc: 'Total debit value in pnl currency.'
          }
        )

        expose(
          :average_buy_price,
          documentation: {
            type: BigDecimal,
            desc: 'Average buy price.'
          }
        )

        expose(
          :average_sell_price,
          documentation: {
            type: BigDecimal,
            desc: 'Average sell price.'
          }
        )

        expose(
          :average_balance_price,
          documentation: {
            type: BigDecimal,
            desc: 'Average balance price.'
          }
        )

        expose(
          :total_balance_value,
          documentation: {
            type: BigDecimal,
            desc: 'Total balance value in pnl currency.'
          }
        )
      end
    end
  end
end
