module Worker
  class TradeStats

    def initialize(market)
      @market = market
      @redis  = Redis.new url: ENV["REDIS_URL"], db: 1
    end

    def run
      [1, 60, 1440, 10080].each do |period|
        collect period
      end
      Rails.logger.info "TradeStats (#{@market.id}) collected."
    end

    def collect(period)
      key = key_for 'trades', period
      loop do
        ts = next_point key, period
        break if (ts + period.minutes) > (Time.now + 30.second) # 30 seconds should be enough to allow data propagate from master to slave

        point = period == 1 ? point_1(ts) : point_n(ts, period)
        @redis.rpush key, point.to_json
      end
    end

    def key_for(type, period)
      "peatio:#{@market.id}:stats:#{type}:#{period}"
    end

    def next_point(key, period=1)
      last = @redis.lindex key, -1
      if last
        ts = Time.at JSON.parse(last)[0]
        ts += period.minutes
      else
        ts = 30.days.ago.beginning_of_day
      end
    end

    def point_1(from)
      to = from + 1.minute
      trades = Trade.with_currency(@market.id).where(created_at: from..to).pluck(:ask_member_id, :bid_member_id)
      trade_users = trades.flatten.uniq
      [from.to_i, trades.size, trade_users.size]
    end

    def point_n(from, period)
      arr = point_1_set from, period
      trades_count = arr.sum {|point| point[1]}
      trade_users_count = arr.sum(&:last)
      [from.to_i, trades_count, trade_users_count]
    end

    def point_1_set(from, period)
      key1 = key_for 'trades', 1
      ts = JSON.parse(@redis.lindex(key1, 0)).first

      offset = [(from.to_i - ts)/60, 0].max
      to = offset + period - 1

      to < offset ? [] : @redis.lrange(key1, offset, to).map {|str| JSON.parse(str) }
    end

  end
end
