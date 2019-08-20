# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'v2/entities/order'

module API
  module V2
    module Entities
      class OrderBook < Base
        expose(
          :asks,
          using: Order,
          documentation: {
            type: 'API::V2::Entities::Order',
            is_array: true,
            desc: 'Asks in orderbook'
          }
        )

        expose(
          :bids,
          using: Order,
          documentation: {
            type: 'API::V2::Entities::Order',
            is_array: true,
            desc: 'Bids in orderbook'
          }
        )
      end
    end
  end
end
