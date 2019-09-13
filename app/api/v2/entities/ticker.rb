# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Ticker < Base
        class TickerEntry < Base
          expose(
            :buy,
            documentation: {
              type: BigDecimal,
              desc: 'Best buy (highest) price in current orderbook (0.0 if there is no buy orders)'
            }
          )

          expose(
            :sell,
            documentation: {
              type: BigDecimal,
              desc: 'Best sell (lowest) price in current orderbook (0.0 if there is no sell orders)'
            }
          )

          expose(
            :low,
            documentation: {
              type: BigDecimal,
              desc: 'The lowest trade price during last 24 hours (0.0 if no trades executed during last 24 hours)'
            }
          )

          expose(
            :high,
            documentation: {
              type: BigDecimal,
              desc: 'The highest trade price during last 24 hours (0.0 if no trades executed during last 24 hours)'
            }
          )

          expose(
            :open,
            documentation: {
              type: BigDecimal,
              desc: 'Price of the first trade executed 24 hours ago or less'
            }
          )

          expose(
            :last,
            documentation: {
              type: BigDecimal,
              desc: 'The last executed trade price'
            }
          )

          expose(
            :volume,
            documentation: {
              type: BigDecimal,
              desc: 'Total amount of trades executed during last 24 hours (recalculated once in 15 minuets)'
            }
          )

          expose(
            :vol,
            documentation: {
              type: BigDecimal,
              desc: 'Alias to volume'
            }
          )

          expose(
            :avg_price,
            documentation: {
              type: BigDecimal,
              desc: 'Average price more precisely VWAP is calculated by adding up the total traded for every transaction'\
                    '(price multiplied by the number of shares traded) and then dividing by the total shares traded'
            }
          )

          expose(
            :price_change_percent,
            documentation: {
              type: String,
              desc: 'Price change in the next format +3.19%.'\
                    'Price change is calculated using next formula (last - open) / open * 100%'
            }
          )
        end

        expose(
          :at,
          documentation: {
            type: Integer,
            desc: 'Timestamp of ticker'
          }
        )

        expose(
          :ticker,
          using: TickerEntry,
          documentation: {
            type: TickerEntry,
            desc: 'Ticker entry for specified time'
          }
        )
      end
    end
  end
end
