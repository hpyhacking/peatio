# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      module Entities
        class Pair < API::V2::Entities::Base
          expose(
            :ticker_id,
            documentation: {
              type: String,
              desc: 'Identifier of a ticker with delimiter to separate base/target, eg. BTC_ETH.'
            }
          ) do |market|
            market.underscore_name
          end

          expose(
            :base,
            documentation: {
              type: String,
              desc: 'Symbol/currency code of a the base cryptoasset, eg. BTC.'
            }
          ) do |market|
            market[:base_unit].upcase
          end

          expose(
            :target,
            documentation: {
              type: String,
              desc: 'Symbol/currency code of the target cryptoasset, eg. ETH.'
            }
          ) do |market|
            market[:quote_unit].upcase
          end
        end
      end
    end
  end
end
