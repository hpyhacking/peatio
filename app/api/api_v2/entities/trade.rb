module APIv2
  module Entities
    class Trade < Base
      expose :id
      expose :price
      expose :volume
      expose :funds
      expose :currency, as: :market
      expose :created_at, format_with: :iso8601

      expose :side do |trade, options|
        options[:side] || trade.side
      end
    end
  end
end
