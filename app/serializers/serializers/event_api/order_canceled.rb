# encoding: UTF-8
# frozen_string_literal: true

module Serializers
  module EventAPI
    class OrderCanceled < OrderEvent
      def call(order)
        super.merge! \
          canceled_at: order.updated_at.iso8601
      end
    end
  end
end
