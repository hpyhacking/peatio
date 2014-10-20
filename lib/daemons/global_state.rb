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
  all_tickers = {}
  Market.enumerize.each_key do |id|
    global = Global[id]
    global.trigger_ticker
    all_tickers[id] = global.ticker
  end
  Global.trigger 'tickers', all_tickers

  sleep 3
end
