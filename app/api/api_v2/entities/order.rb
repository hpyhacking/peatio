module APIv2
  module Entities
    class Order < Base
      expose :id, documentation: {
        type: "Integer", desc: "Unique order id." }

      expose :side, documentation: {
        type: "String", desc: "Either 'sell' or 'buy'." }

      expose :price, documentation: {
        type: "String", desc: "Price for each unit. e.g. If you want to sell/buy 1 btc at 3000 CNY, the price is '3000.0'" }

      expose :state, documentation: {
        type: "String", desc: "One of 'wait', 'done', or 'cancel'. An order in 'wait' is an active order, waiting fullfillment; a 'done' order is an order fullfilled; 'cancel' means the order has been cancelled." }

      expose :currency, as: :market, documentation: {
        type: "String", desc: "The market in which the order is placed, e.g. 'btccny'. All available markets can be found at /api/v2/markets."
      }

      expose :created_at, format_with: :iso8601, documentation: {
        type: "String", desc: "Order create time in iso8601 format."
      }

      expose :origin_volume, as: :volume, documentation: {
        type: "String", desc: "The amount user want to sell/buy. An order could be partially executed, e.g. an order sell 5 btc can be matched with a buy 3 btc order, left 2 btc to be sold; in this case the order's volume would be '5.0', its remaining_volume would be '2.0', its executed volume is '3.0'." }

      expose :volume, as: :remaining_volume, documentation: {
        type: "String", desc: "The remaining volume, see 'volume'." }

      expose :executed_volume, documentation: {
        type: "String", desc: "The executed volume, see 'volume'."
      } do |order, options|
        order.origin_volume - order.volume
      end

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
