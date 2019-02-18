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
          :volume,
          documentation: {
            type: BigDecimal,
            desc: 'Trade volume.'
          }
        )

        expose(
          :funds,
          documentation: {
            type: BigDecimal,
            desc: 'Trade funds.'
          }
        )

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
            desc: 'Trade maker order type (sell or buy).'
          }
        ) do |trade, _options|
            trade.ask_id > trade.bid_id ? :sell : :buy
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
            if trade.ask_member_id == options[:current_user].id
              trade.ask_id
            elsif trade.bid_member_id == options[:current_user].id
              trade.bid_id
            else
              nil
            end
          end
      end
    end
  end
end
