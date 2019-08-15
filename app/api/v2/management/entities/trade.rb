# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
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
              desc: 'Trade total.'
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
            :maker_order_id,
            documentation: {
              type: String,
              desc: 'Trade maker order id.'
            }
          )

          expose(
            :taker_order_id,
            documentation: {
              type: String,
              desc: 'Trade taker order id.'
            }
          )

          expose(
            :maker_member_uid,
            documentation: {
              type: String,
              desc: 'Trade ask member uid.'
            }
          ) do |trade|
            trade.maker.uid
          end

          expose(
            :taker_member_uid,
            documentation: {
              type: String,
              desc: 'Trade bid member uid.'
            }
          ) do |trade|
            trade.taker.uid
          end

          expose(
            :taker_type,
            documentation: {
              type: String,
              desc: 'Trade maker order type (sell or buy).'
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
            options[:side] || trade.order_for_member(options[:current_user]).side
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
        end
      end
    end
  end
end
