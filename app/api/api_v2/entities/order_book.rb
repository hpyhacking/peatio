# encoding: UTF-8
# frozen_string_literal: true

require_dependency 'api_v2/entities/order'

module APIv2
  module Entities
    class OrderBook < Base
      expose :asks, using: Order
      expose :bids, using: Order
    end
  end
end
