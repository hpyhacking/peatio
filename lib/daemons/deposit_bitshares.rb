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

btsx_deposit = Worker::DepositBitshares.new 'btsx'
dns_deposit  = Worker::DepositBitshares.new 'dns'

def safe_process(worker)
  worker.process
rescue
  Rails.logger.error "Worker failure: #{$!}"
  Rails.logger.error $!.backtrace.join("\n")
end

while($running) do
  safe_process btsx_deposit
  safe_process dns_deposit
  sleep 5 # half of block production time
end
