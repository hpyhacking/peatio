# encoding: UTF-8
# frozen_string_literal: true

module Serializers
  module EventAPI
    class OrderEvent
      def call(order)
        { market:                 order.market_id,
          type:                   type(order),
          trader_uid:             Member.uid(order.member_id),
          income_unit:            buy?(order) ? order.ask : order.bid,
          income_fee_type:        'relative',
          income_fee_value:       order.fee.to_s('F'),
          outcome_unit:           buy?(order) ? order.bid : order.ask,
          outcome_fee_type:       'relative',
          outcome_fee_value:      '0.0',
          initial_income_amount:  initial_income_amount(order),
          current_income_amount:  current_income_amount(order),
          initial_outcome_amount: initial_outcome_amount(order),
          current_outcome_amount: current_outcome_amount(order),
          strategy:               order.ord_type,
          price:                  order.price.to_s('F'),
          state:                  state(order),
          trades_count:           order.trades_count,
          created_at:             order.created_at.iso8601 }
      end

      class << self
        def call(order)
          new.call(order)
        end
      end

    private
      def state(order)
        case order.state
          when Order::CANCEL then 'canceled'
          when Order::DONE   then 'completed'
          else 'open'
        end
      end

      def type(order)
        OrderBid === order ? 'buy' : 'sell'
      end

      def buy?(order)
        type(order) == 'buy'
      end

      def sell?(order)
        !buy?(order)
      end

      def initial_income_amount(order)
        multiplier = buy?(order) ? 1.0 : order.price
        amount     = order.origin_volume
        (amount * multiplier).to_s('F')
      end

      def current_income_amount(order)
        multiplier = buy?(order) ? 1.0 : order.price
        amount     = order.volume
        (amount * multiplier).to_s('F')
      end

      def previous_income_amount(order)
        changes    = order.previous_changes
        multiplier = buy?(order) ? 1.0 : order.price
        amount     = changes.key?('volume') ? changes['volume'][0] : order.volume
        (amount * multiplier).to_s('F')
      end

      def initial_outcome_amount(order)
        attribute = buy?(order) ? 'origin_locked' : 'origin_volume'
        order.send(attribute).to_s('F')
      end

      def current_outcome_amount(order)
        attribute = buy?(order) ? 'locked' : 'volume'
        order.send(attribute).to_s('F')
      end

      def previous_outcome_amount(order)
        changes   = order.previous_changes
        attribute = buy?(order) ? 'locked' : 'volume'
        (changes.key?(attribute) ? changes[attribute][0] : order.send(attribute)).to_s('F')
      end
    end
  end
end
