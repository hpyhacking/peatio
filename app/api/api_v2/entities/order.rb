module APIv2
  module Entities
    class Order < Grape::Entity
      format_with(:iso8601) {|t| t.iso8601 }

      expose :id
      expose :price
      expose :state
      expose :currency, as: :market
      expose :created_at, format_with: :iso8601

      expose :origin_volume, as: :volume
      expose :volume, as: :remaining_volume
      expose :executed_volume do |order, options|
        order.origin_volume - order.volume
      end

      expose :side do |order, options|
        order.type[-3, 3] == 'Ask' ? 'sell' : 'buy'
      end
    end
  end
end
