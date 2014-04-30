#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

Rails.logger = logger = Logger.new STDOUT

EM.run do
  conn = AMQP.connect AMQPConfig.connect
  logger.info "Connected to AMQP broker."

  ch = AMQP::Channel.new conn
  ch.prefetch(1)

  x = ch.send *AMQPConfig.exchange(:octopus)

  EM::WebSocket.run(host: '0.0.0.0', port: 8080) do |ws|
    logger.debug "New WebSocket connection: #{ws.inspect}"

    ws.onopen do
      q = ch.queue '', auto_delete: true
      q.bind(x, routing_key: 'trade.#')
      q.subscribe(ack: true) do |metadata, payload|
        EM.defer -> {
          payload = JSON.parse payload
          trade = Trade.find_by_id payload['id']
          ask   = Order.find_by_id payload['ask_id']
          trade
        }, ->(trade) {
          if trade.is_a?(::Trade)
            entity = ::APIv2::Entities::Trade.represent trade, side: 'ask'
            ws.send entity.to_json
          end
          metadata.ack
        }
      end
    end

    ws.onmessage do |msg|
    end

    ws.onerror do |error|
      case error
      when EM::WebSocket::WebSocketError
        logger.info "WebSocket error: #{$!}"
      else
      end
    end

    ws.onclose do
      logger.info "WebSocket closed"
    end
  end
end
