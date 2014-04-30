module APIv2
  module Entities
    class Trade < Base
      expose :id
      expose :price
      expose :volume
      expose :currency, as: :market
      expose :created_at, format_with: :iso8601

      expose :side do |trade, options|
        options[:side] || trade.side
      end

      expose :ask, if: {include_order: :ask} do |trade, options|
        ::APIv2::Entities::Order.represent trade.ask
      end

      expose :bid, if: {include_order: :bid} do |trade, options|
        ::APIv2::Entities::Order.represent trade.bid
      end
    end
  end
end
