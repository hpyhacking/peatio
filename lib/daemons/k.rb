# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), "config", "environment")

@logger = Rails.logger

@r ||= KlineDB.redis

$running = true
Signal.trap("TERM") do
  $running = false
end


def key(market, period = 1)
  "peatio:#{market}:k:#{period}"
end

def last_ts(market, period = 1)
  latest = @r.lindex key(market, period), -1
  latest && Time.at(JSON.parse(latest)[0])
end

def next_ts(market, period = 1)
  if ts = last_ts(market, period)
    ts += period.minutes
  else
    if first_trade = Trade.with_market(market).order(created_at: :asc).first
      ts = first_trade.created_at.to_i
      period == 10080 ? Time.at(ts).beginning_of_week : Time.at(ts -  ts % (period * 60))
    end
  end
end

def _k1_set(market, start, period)
  ts = JSON.parse(@r.lindex(key(market, 1), 0)).first

  left = offset = (start.to_i - ts) / 60
  left = 0 if left < 0

  right = offset + period - 1

  right < 0 ? [] : @r.lrange(key(market, 1), left, right).map{|str| JSON.parse(str)}
end

def k1(market, start)
  trades = Trade
             .with_market(market)
             .where('created_at >= ? AND created_at < ?', start, 1.minutes.since(start))
             .pluck(:price, :volume)
  return nil if trades.count == 0

  prices, volumes = trades.transpose
  [start.to_i, prices.first.to_f, prices.max.to_f, prices.min.to_f, prices.last.to_f, volumes.sum.to_f.round(4)]
end

def kn(market, start, period = 5)
  arr = _k1_set(market, start, period)
  return nil if arr.empty?

  _, _, high, low, _, volumes = arr.transpose
  [start.to_i, arr.first[1], high.max, low.min, arr.last[4], volumes.sum.round(4)]
end

def get_point(market, period, ts)
  point = period == 1 ? k1(market, ts) : kn(market, ts, period)

  if point.nil?
    point = JSON.parse @r.lindex(key(market, period), -1)
    point = [ts.to_i, point[4], point[4], point[4], point[4], 0]
  end

  point
end

def append_point(market, period, ts)
  k = key(market, period)
  point = get_point(market, period, ts)

  @logger.info { "append #{k}: #{point.to_json}" }
  @r.rpush k, point.to_json

  if period == 1
    # 24*60 = 1440
    if point = @r.lindex(key(market, period), -1441)
      Rails.cache.write "peatio:#{market}:ticker:open", JSON.parse(point)[4]
    end
  end
end

def update_point(market, period, ts)
  k = key(market, period)
  point = get_point(market, period, ts)

  @logger.info { "update #{k}: #{point.to_json}" }
  @r.rpop k
  @r.rpush k, point.to_json
end

def fill(market, period = 1)
  ts = next_ts(market, period)

  # 30 seconds is a protect buffer to allow update_point to update the previous
  # period one last time, after the previous period passed. After the protect
  # buffer a new point of current period will be created, the previous point
  # is freezed.
  #
  # The protect buffer also allows MySQL slave have enough time to sync data.
  while (ts + 30.seconds) <= Time.now
    append_point(market, period, ts)
    ts = next_ts(market, period)
  end

  update_point(market, period, last_ts(market, period))
end

while($running) do
  # NOTE: Turn off ticker updates for disabled markets.
  Market.enabled.each do |market|
    ts = next_ts(market.id, 1)
    next unless ts

    [1, 5, 15, 30, 60, 120, 240, 360, 720, 1440, 4320, 10080].each do |period|
      fill(market.id, period)
    end
  end

  sleep 15
end
