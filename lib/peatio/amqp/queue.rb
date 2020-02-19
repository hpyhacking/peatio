# encoding: UTF-8
# frozen_string_literal: true

module AMQP
  class Queue

    class <<self
      def connection
        @connection ||= Bunny.new(AMQP::Config.connect).tap do |conn|
          conn.start
        end
      end

      def channel
        @channel ||= connection.create_channel
      end

      def exchanges
        @exchanges ||= {default: channel.default_exchange}
      end

      def exchange(id)
        exchanges[id] ||= channel.send *AMQP::Config.exchange(id)
      end

      def publish(eid, payload, attrs={})
        payload = JSON.dump payload
        exchange(eid).publish(payload, attrs)
      end

      # enqueue = publish to direct exchange
      def enqueue(id, payload, attrs={})
        eid = AMQP::Config.binding_exchange_id(id) || :default
        attrs.merge!({routing_key: AMQP::Config.routing_key(id)})
        publish(eid, payload, attrs)
      end

      def enqueue_event(type, id, event, payload, opts={})
        routing_key = [type, id, event].join('.')
        serialized_data = JSON.dump(payload)
        channel.exchange('peatio.events.ranger', type: 'topic').publish(serialized_data, routing_key: routing_key)
      end
    end
  end
end
