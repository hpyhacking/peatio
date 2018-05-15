# encoding: UTF-8
# frozen_string_literal: true

module Serializers
  module EventAPI
    class OrderCompleted < OrderEvent
      def call(order)
        super.merge! \
          previous_income_amount:  previous_income_amount(order),
          previous_outcome_amount: previous_outcome_amount(order),
          completed_at:            order.updated_at.iso8601
      end
    end
  end
end
