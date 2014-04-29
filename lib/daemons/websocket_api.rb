#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

Rails.logger = logger = Logger.new STDOUT

EM::WebSocket.start(host: '0.0.0.0', port: 8080) do |ws|
  logger.info "WebSocket server started."

  ws.onopen do
    logger.info "WebSocket opened"
    ws.send "hello"
  end

  ws.onmessage do |msg|
    logger.info "Received: #{msg}"
    ws.send "Pong: #{msg}"
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
