#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do
  $running = false
end

Rails.logger = Logger.new STDOUT

worker = Worker::DepositBtsx.new
duration = Worker::DepositBtsx::BLOCK_DURATION / 2

while($running) do
  begin
    worker.process
  rescue
    Rails.logger.error "Worker failure: #{$!}"
    Rails.logger.error $!.backtrace.join("\n")
  end

  sleep duration
end
