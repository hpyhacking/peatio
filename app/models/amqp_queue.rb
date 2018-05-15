# encoding: UTF-8
# frozen_string_literal: true

class AMQPQueue

  class <<self
    def connection
      @connection ||= Bunny.new(AMQPConfig.connect).tap do |conn|
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
      exchanges[id] ||= channel.send *AMQPConfig.exchange(id)
    end

    def publish(eid, payload, attrs={})
      payload = JSON.dump payload
      exchange(eid).publish(payload, attrs)
    end

    # enqueue = publish to direct exchange
    def enqueue(id, payload, attrs={})
      eid = AMQPConfig.binding_exchange_id(id) || :default
      payload.merge!({locale: I18n.locale})
      attrs.merge!({routing_key: AMQPConfig.routing_key(id)})
      publish(eid, payload, attrs)
    end
  end
end
