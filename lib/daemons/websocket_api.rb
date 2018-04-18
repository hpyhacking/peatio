# frozen_string_literal: true

require 'em-websocket'

require File.expand_path('../../config/environment', __dir__)
require_dependency 'api_v2/websocket_protocol'

Rails.logger = logger = Logger.new STDOUT

EM.error_handler do |e|
  logger.error "Error: #{e}"
  logger.error e.backtrace[0,20].join("\n")
end

EM.run do
  conn = Bunny.new AMQPConfig.connect
  conn.start

  ch = conn.create_channel
  ch.prefetch(1)

  config = {host: ENV['WEBSOCKET_HOST'], port: ENV['WEBSOCKET_PORT']}
  if ENV['WEBSOCKET_SSL_KEY'] && ENV['WEBSOCKET_SSL_CERT']
    config[:secure] = true
    config[:tls_options] = {
      private_key_file: Rails.root.join(ENV['WEBSOCKET_SSL_KEY']).to_s,
      cert_chain_file: Rails.root.join(ENV['WEBSOCKET_SSL_CERT']).to_s
    }
  end

  EM::WebSocket.run(config) do |ws|
    logger.debug "New WebSocket connection: #{ws.inspect}"

    protocol = ::APIv2::WebSocketProtocol.new(ws, ch, logger)

    ws.onopen do
      if ws.pingable?
        port, ip = Socket.unpack_sockaddr_in(ws.get_peername)

        EM.add_periodic_timer 10 do
          ws.ping "#{ip}:#{port}"
        end

        ws.onpong do |message|
          logger.debug "pong: #{message}"
        end
      end

      protocol.challenge
    end

    ws.onmessage do |message|
      protocol.handle message
    end

    ws.onerror do |error|
      case error
      when EM::WebSocket::WebSocketError
        logger.info "WebSocket error: #{$!}"
        logger.info $!.backtrace[0,20].join("\n")
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
