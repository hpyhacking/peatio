#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  Market.enumerize.each_key do |currency|
    Global[currency].tap do |global|
      global.update_asks
      global.update_bids
      global.update_trades
      global.update_ticker
      global.trigger
    end
  end
  sleep 5
end
