module APIv2
  module NamedParams
    extend ::Grape::API::Helpers

    params :auth do
      requires :access_key, type: String,  desc: "Access key."
      requires :tonce,      type: Integer, desc: "Tonce is an integer represents the milliseconds elapsed since Unix epoch."
      requires :signature,  type: String,  desc: "The signature of your request payload, generated using your secret key."
    end

    params :market do
      requires :market, type: String, values: ::Market.all.map(&:id), desc: ::APIv2::Entities::Market.documentation[:id]
    end

    params :order do
      requires :side,   type: String, values: %w(sell buy), desc: ::APIv2::Entities::Order.documentation[:side]
      requires :volume, type: String, desc: ::APIv2::Entities::Order.documentation[:volume]
      optional :price,  type: String, desc: ::APIv2::Entities::Order.documentation[:price]
    end

    params :order_id do
      requires :id, type: Integer, desc: ::APIv2::Entities::Order.documentation[:id]
    end

    params :trade_filters do
      optional :limit,     type: Integer, range: 1..1000, default: 50, desc: 'Limit the number of returned trades. Default to 50.'
      optional :timestamp, type: Integer, desc: "An integer represents the seconds elapsed since Unix epoch. If set, only trades executed after the time will be returned."
    end

  end
end
