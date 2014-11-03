module Worker
  class Stats

    def initialize
      @redis  = Redis.new url: ENV["REDIS_URL"], db: 1
    end

    def run
      [1, 60, 1440, 10080].each do |period|
        collect period
      end
      Rails.logger.info "#{self.to_s} collected."
    end

    def to_s
      self.class.name
    end

    def key_for(period)
      raise "abstract method"
    end

    def point_1(from)
      raise "abstract method"
    end

    def point_n(from)
      raise "abstract method"
    end

    def collect(period)
      key = key_for period
      loop do
        ts = next_point key, period
        break if (ts + period.minutes) > (Time.now + 30.second) # 30 seconds should be enough to allow data propagate from master to slave

        point = period == 1 ? point_1(ts) : point_n(ts, period)
        @redis.rpush key, point.to_json
      end
    end

    def next_point(key, period=1)
      last = @redis.lindex key, -1
      if last
        ts = Time.at JSON.parse(last)[0]
        ts += period.minutes
      else
        ts = 7.days.ago(Time.now.beginning_of_day)
      end
    end

    def point_1_set(from, period)
      key1 = key_for 1
      ts = JSON.parse(@redis.lindex(key1, 0)).first

      offset = [(from.to_i - ts)/60, 0].max
      to = offset + period - 1

      to < offset ? [] : @redis.lrange(key1, offset, to).map {|str| JSON.parse(str) }
    end

    def get_point(ts, period)
      key = key_for period
      first_ts = JSON.parse(@redis.lindex(key, 0)).first

      offset = (ts-first_ts) / (60*period)
      return if offset < 0

      JSON.parse @redis.lindex(key, offset)
    end

  end
end
