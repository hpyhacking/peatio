#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

Rails.logger = logger = Logger.new STDOUT

EM.error_handler do |e|
  logger.error "Error: #{e}"
  logger.error e.backtrace[0,20].join("\n")
end

EM.run do
  conn = AMQP.connect AMQPConfig.connect
  logger.info "Connected to AMQP broker."

  ch = AMQP::Channel.new conn
  ch.prefetch(1)

  EM::WebSocket.run(host: '0.0.0.0', port: 8080) do |ws|
    logger.debug "New WebSocket connection: #{ws.inspect}"

    protocol = ::APIv2::WebSocketProtocol.new(ws, ch, logger)

    ws.onopen do
      protocol.challenge
    end

    ws.onmessage do |message|
      protocol.handle message
    end

    ws.onerror do |error|
      case error
      when EM::WebSocket::WebSocketError
        logger.info "WebSocket error: #{$!}"
        logger.info $!.backtrade[0,20].join("\n")
        logger.info $!.inspect
      else
        logger.info $!
      end
    end

    ws.onclose do
      logger.info "WebSocket closed"
    end
  end
end
