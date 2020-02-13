module Workers
  module AMQP
    class InfluxWriter < Base
      def process(payload, metadata, _delivery_info)
        case metadata[:headers]['type']
        when 'local'
          trade = Trade.new payload
          trade.write_to_influx
        end
      end
    end
  end
end
