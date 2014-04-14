class AMQPQueue

  class <<self
    def connection
      @connection ||= Bunny.new(AMQP_CONFIG[:connect]).tap do |conn|
        conn.start
      end
    end

    def channel
      @channel ||= connection.create_channel
    end

    def enqueue(queue, payload)
      channel.default_exchange.publish(payload, routing_key: AMQP_CONFIG[:queue][queue])
    end
  end

end
