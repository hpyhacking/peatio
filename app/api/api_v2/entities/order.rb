# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Order < Base
      expose :id, documentation: "Unique order id."

      expose :side, documentation: "Either 'sell' or 'buy'."
      expose :ord_type, documentation: "Type of order, either 'limit' or 'market'."

      expose :price, documentation: "Price for each unit. e.g. If you want to sell/buy 1 btc at 3000 usd, the price is '3000.0'"

      expose :avg_price, documentation: "Average execution price, average of price in trades."

      expose :state, documentation: "One of 'wait', 'done', or 'cancel'. An order in 'wait' is an active order, waiting fulfillment; a 'done' order is an order fulfilled; 'cancel' means the order has been canceled."

      expose :market_id, as: :market, documentation: "The market in which the order is placed, e.g. 'btcusd'. All available markets can be found at /api/v2/markets."

      expose :created_at, format_with: :iso8601, documentation: "Order create time in iso8601 format."

      expose :origin_volume, as: :volume, documentation: "The amount user want to sell/buy. An order could be partially executed, e.g. an order sell 5 btc can be matched with a buy 3 btc order, left 2 btc to be sold; in this case the order's volume would be '5.0', its remaining_volume would be '2.0', its executed volume is '3.0'."

      expose :volume, as: :remaining_volume, documentation: "The remaining volume, see 'volume'."

      expose :executed_volume, documentation: "The executed volume, see 'volume'." do |order, options|
        order.origin_volume - order.volume
      end

      expose :trades_count
      expose :trades, if: {type: :full} do |order, options|
        ::APIv2::Entities::Trade.represent order.trades, side: side
      end

      private

      def side
        @side ||= @object.type[-3, 3] == 'Ask' ? 'sell' : 'buy'
      end

    end
  end
end
