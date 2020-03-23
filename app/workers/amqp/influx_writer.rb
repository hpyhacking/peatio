# frozen_string_literal: true

module Workers
  module AMQP
    class InfluxWriter < Base
      def process(payload, metadata, _delivery_info)
        case metadata[:headers]['type']
        when 'local'
          trade = Trade.new payload
          trade.write_to_influx
        when 'upstream'
          trade = Trade.new payload.merge(total: payload['price'].to_d * payload['amount'].to_d)
          trade.write_to_influx
        end
      end
    end
  end
end
