# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      module Entities
        class Orderbook < API::V2::Entities::Base
          expose(
            :ticker_id,
            documentation: {
              type: String,
              desc: 'A pair such as "BTC_ETH", with delimiter between different cryptoassets.'
            }
          ) do |orderbook|
            orderbook.market.underscore_name
          end

          expose(
            :timestamp,
            documentation: {
              type: Integer,
              desc: 'Unix timestamp in milliseconds for when the last updated time occurred'
            }
          ) do
            DateTime.now.strftime('%Q').to_i
          end

          expose(
            :asks,
            documentation: {
              type: BigDecimal,
              is_array: true,
              desc: 'An array containing 2 elements. The offer price and quantity for each bid order.'
            }
          )

          expose(
            :bids,
            documentation: {
              type: BigDecimal,
              is_array: true,
              desc: 'An array containing 2 elements. The ask price and quantity for each ask order.'
            }
          )
        end
      end
    end
  end
end
