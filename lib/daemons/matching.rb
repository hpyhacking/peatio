#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

class EchoServer < EM::Connection
  def receive_data(data)
    if data.strip =~ /exit$/i
      EM.stop
    else
      send_data(data)
    end
  end
end

EM.run do
  Signal.trap("INT")  { puts "INT received, stop";  EM.stop_event_loop }
  Signal.trap("TERM") { puts "TERM received, stop"; EM.stop_event_loop }

  Rails.logger.info "started at #{Time.now}.\n"

  EM.start_server('0.0.0.0', 10000, EchoServer)
end
