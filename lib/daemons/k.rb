#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "development"

root = File.expand_path(File.dirname(__FILE__))
root = File.dirname(root) until File.exists?(File.join(root, 'config'))
Dir.chdir(root)

require File.join(root, "config", "environment")

Rails.logger = @logger = Logger.new STDOUT

@r = Redis.new db: 1

$running = true
Signal.trap("TERM") do
  $running = false
end

def key(market, period = 1)
  "#{market}-k#{period}"
end

def next_ts(market, period = 1)
  latest = @r.lindex key(market, period), -1
  if latest
    ts = Time.at(JSON.parse(latest)[0])
    ts += period.minutes
  else
    ts = Trade.with_currency(market).first.created_at.to_i
    ts = Time.at(ts -  ts % (period * 60))
  end
end

def OHLC(market, start, period = 1)
  trades = Trade.with_currency(market).where(created_at: start..(start + period.minutes)).pluck(:price, :volume)
  return nil if trades.count == 0

  prices, volumes = trades.transpose
  [start.to_i, prices.first.to_f, prices.max.to_f, prices.min.to_f, prices.last.to_f, volumes.reduce(&:+).to_f.round(4)]
end

def fill(market, period = 1)
  loop do
    ts = next_ts(market, period)
    break if ts + period.minutes > Time.now + 1.second

    k = OHLC(market, ts, period)
    if k.nil?
      k = JSON.parse @r.lindex(key(market, period), -1)
      k = [ts.to_i, k[4], k[4], k[4], k[4], 0]
    end

    @logger.info "#{key(market, period)}: #{k.to_json}"
    @r.rpush key(market, period), k.to_json
  end
end

while($running) do
  Market.all.each do |market|
    [1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080].each do |period|
      fill(market.id, period)
    end
  end
  sleep 5
end
