# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'v2/entities/order'

module API
  module V2
    module Entities
      class OrderBook < Base
        expose :asks, using: Order
        expose :bids, using: Order
      end
    end
  end
end