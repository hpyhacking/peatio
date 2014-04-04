module APIv2
  module Entities
    class Order < Grape::Entity
      format_with(:iso8601) {|t| t.iso8601 }

      expose :id
      expose :price
      expose :origin_volume, as: :volume
      expose :state
      expose :currency, as: :market
      expose :created_at, format_with: :iso8601

      expose :side do |order, options|
        order.type[-3, 3] == 'Ask' ? 'Sell' : 'Buy'
      end
    end
  end
end
