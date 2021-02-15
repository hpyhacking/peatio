# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Market
      module NamedParams
        extend ::Grape::API::Helpers

        params :enabled_markets do
          requires :market,
                   type: String,
                   values: { value: -> { ::Market.active.ids }, message: 'market.market.doesnt_exist_or_not_enabled' },
                   desc: -> { V2::Entities::Market.documentation[:id] }
        end

        params :order do
          requires :side,
                   type: String,
                   values: { value: %w(sell buy), message: 'market.order.invalid_side' },
                   desc: -> { V2::Entities::Order.documentation[:side] }
          requires :volume,
                   type: { value: BigDecimal, message: 'market.order.non_decimal_volume' },
                   values: { value: -> (v){ v.try(:positive?) }, message: 'market.order.non_positive_volume' },
                   desc: -> { V2::Entities::Order.documentation[:volume] }
          optional :ord_type,
                   type: String,
                   values: { value: -> { Order::TYPES }, message: 'market.order.invalid_type' },
                   default: 'limit',
                   desc: -> { V2::Entities::Order.documentation[:type] }
          given ord_type: ->(val) { val == 'limit' } do
            requires :price,
                     type: { value: BigDecimal, message: 'market.order.non_decimal_price' },
                     values: { value: -> (p){ p.try(:positive?) }, message: 'market.order.non_positive_price' },
                     desc: -> { V2::Entities::Order.documentation[:price] }
          end
        end

        params :order_id do
          requires :id,
                   type: String,
                   allow_blank: false,
                   desc: -> { V2::Entities::Order.documentation[:id] }
        end

        params :trade_filters do
          optional :limit,
                   type: { value: Integer, message: 'market.trade.non_integer_limit' },
                   values: { value: 1..1000, message: 'market.trade.invalid_limit' },
                   default: 100,
                   desc: 'Limit the number of returned trades. Default to 100.'
          optional :page,
                   type: { value: Integer, message: 'market.trade.non_integer_page' },
                   allow_blank: false,
                   default: 1,
                   desc: 'Specify the page of paginated results.'
          optional :type,
                   type: String,
                   values: { value: %w(buy sell), message: 'market.trade.invalid_type' },
                   desc: 'To indicate nature of trade - buy/sell'
          optional :time_from,
                   type: { value: Integer, message: 'market.trade.non_integer_time_from' },
                   allow_blank: { value: false, message: 'market.trade.empty_time_from' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only trades executed after the time will be returned."
          optional :time_to,
                   type: { value: Integer, message: 'market.trade.non_integer_time_to' },
                   allow_blank: { value: false, message: 'market.trade.empty_time_to' },
                   desc: "An integer represents the seconds elapsed since Unix epoch."\
                         "If set, only trades executed before the time will be returned."
          optional :order_by,
                   type: String,
                   values: { value: %w(asc desc), message: 'market.trade.invalid_order_by' },
                   default: 'desc',
                   desc: "If set, returned trades will be sorted in specific order, default to 'desc'."
        end
      end
    end
  end
end
