module APIv2
  module Entities
    class Order < Base
      expose :id
      expose :side
      expose :price
      expose :state
      expose :currency, as: :market
      expose :created_at, format_with: :iso8601

      expose :origin_volume, as: :volume
      expose :volume, as: :remaining_volume
      expose :executed_volume do |order, options|
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
