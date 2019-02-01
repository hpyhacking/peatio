# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module NamedParams
      extend ::Grape::API::Helpers

      params :currency do
        requires :currency,
                type: String,
                values: -> { Currency.enabled.pluck(:id) },
                desc: 'The currency code.'
      end

      params :market do
        requires :market,
                type: String,
                desc: -> { V2::Entities::Market.documentation[:id] },
                values: -> { ::Market.enabled.ids }
      end

      params :order do
        requires :side,     type: String, values: %w(sell buy), desc: -> { V2::Entities::Order.documentation[:side] }
        requires :volume,   type: Float, desc: -> { V2::Entities::Order.documentation[:volume] }
        optional :ord_type, type: String, values: -> { Order::TYPES }, default: 'limit', desc: -> { V2::Entities::Order.documentation[:type] }
        given ord_type: ->(val) { val == 'limit' } do
          requires :price, type: Float, desc: -> { V2::Entities::Order.documentation[:price] }
        end
      end

      params :order_id do
        requires :id, type: Integer, desc: -> { V2::Entities::Order.documentation[:id] }
      end

      params :trade_filters do
        optional :limit,     type: Integer, range: 1..1000, default: 100, desc: 'Limit the number of returned trades. Default to 100.'
        optional :page,      type: Integer, default: 1, desc: 'Specify the page of paginated results.'
        optional :timestamp, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only trades executed before the time will be returned."
        optional :order_by,  type: String, values: %w(asc desc), default: 'desc', desc: "If set, returned trades will be sorted in specific order, default to 'desc'."
      end
    end
  end
end
