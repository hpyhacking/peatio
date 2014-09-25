module RedisCache
  class << self
    def kline
      @kline ||= Redis.new url: ENV["REDIS_URL"], db: 1
    end
  end
end
