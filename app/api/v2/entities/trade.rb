# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Entities
      class Trade < Base
        expose(
          :id,
          documentation: {
            type: String,
            desc: 'Trade ID.'
          }
        )

        expose(
          :price,
          documentation: {
            type: BigDecimal,
            desc: 'Trade price.'
          }
        )

        expose(
          :amount,
          documentation: {
            type: BigDecimal,
            desc: 'Trade amount.'
          }
        )

        expose(
          :total,
          documentation: {
            type: BigDecimal,
            desc: 'Trade total (Amount * Price).'
          }
        )

        expose(
          :fee_currency,
          documentation: {
            type: BigDecimal,
            desc: 'Currency user\'s fees were charged in.'
          },
          if: ->(_, options) { options[:current_user] }
        ) do |trade, options|
            fee_currency(trade.order_for_member(options[:current_user]))
          end

        expose(
          :fee,
          documentation: {
            type: BigDecimal,
            desc: 'Percentage of fee user was charged for performed trade.'
          },
          if: ->(_, options) { options[:current_user] }
        ) do |trade, options|
            trade.order_fee(trade.order_for_member(options[:current_user]))
          end

        expose(
          :fee_amount,
          documentation: {
            type: BigDecimal,
            desc: 'Amount of fee user was charged for performed trade.'
          },
          if: ->(_, options) { options[:current_user] }
        ) do |trade, options|
            fee_amount(trade, trade.order_for_member(options[:current_user]))
          end

        expose(
          :market_id,
          as: :market,
          documentation: {
            type: String,
            desc: 'Trade market id.'
          }
        )

        expose(
          :created_at,
          format_with: :iso8601,
          documentation: {
            type: String,
            desc: 'Trade create time in iso8601 format.'
          }
        )

        expose(
          :taker_type,
          documentation: {
            type: String,
            desc: 'Trade taker order type (sell or buy).'
          }
        ) do |trade, _options|
          trade.taker_order.side
        end

        expose(
          :side,
          if: ->(trade, options) { options[:side] || options[:current_user] },
          documentation: {
            type: String,
            desc: 'Trade side.'
          }
        ) do |trade, options|
          options[:side] || trade.side(options[:current_user])
        end

        expose(
          :order_id,
          documentation: {
            type: Integer,
            desc: 'Order id.'
          },
          if: ->(_, options) { options[:current_user] }
        ) do |trade, options|
          trade.order_for_member(options[:current_user]).id
        end

        def fee_amount(trade, order)
          trade.order_fee(order) * (order.side == 'buy' ? trade.amount : trade.total)
        end

        def fee_currency(order)
          order.side == 'buy' ? order.ask : order.bid
        end
      end
    end
  end
end
