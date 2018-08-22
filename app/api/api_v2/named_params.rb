# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module NamedParams
    extend ::Grape::API::Helpers

    params :market do
      requires :market,
               type: String,
               desc: -> { APIv2::Entities::Market.documentation[:id] },
               values: -> { Market.enabled.ids }
    end

    params :order do
      requires :side,     type: String, values: %w(sell buy), desc: -> { APIv2::Entities::Order.documentation[:side] }
      requires :volume,   type: String, desc: -> { APIv2::Entities::Order.documentation[:volume] }
      optional :price,    type: String, desc: -> { APIv2::Entities::Order.documentation[:price] }
      optional :ord_type, type: String, values: -> { Order::TYPES }, default: 'limit', desc: -> { APIv2::Entities::Order.documentation[:type] }
    end

    params :order_id do
      requires :id, type: Integer, desc: -> { APIv2::Entities::Order.documentation[:id] }
    end

    params :trade_filters do
      optional :limit,     type: Integer, range: 1..1000, default: 50, desc: 'Limit the number of returned trades. Default to 50.'
      optional :timestamp, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only trades executed before the time will be returned."
      optional :from,      type: Integer, regexp: /^[0-9]*$/ ,validate_from_to: true, allow_blank: false, desc: "Trade id. If set, only trades created after the trade will be returned."
      optional :to,        type: Integer, regexp: /^[0-9]*$/ , allow_blank: false, desc: "Trade id. If set, only trades created before the trade will be returned."
      optional :order_by,  type: String, values: %w(asc desc), default: 'desc', desc: "If set, returned trades will be sorted in specific order, default to 'desc'."
    end
  end
end
