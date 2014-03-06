#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

pids = []

Signal.trap(:TERM) do 
  pids.each do |pid|
    Process.kill(:TERM, pid)
  end
end

Market.all.each do |market|
  pids << fork do
    currency = market.id.to_sym
    $PROGRAM_NAME = "price_matching::#{currency}"

    trap(:TERM) do exit end

    loop do
      matching = Matching.new(currency)
      result = matching.run(Trade.latest_price(currency))

      if result == :idle
        sleep 0.5
      else
        Global[currency].trigger_trade(result)
      end
    end
  end
end

Process.waitall
