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
  Market.all.each do |market|
    global = Global[market.id]
    global.trigger_ticker
    market_unit = {base_unit: market.base_unit, quote_unit: market.quote_unit}
    all_tickers[market.id] = global.ticker.merge(market_unit)
  end
  Global.trigger 'tickers', all_tickers

  sleep 3
end
