namespace :stats do

  def asset_value(ts, currency, amount)
    if currency.code != Currency.fiats.first.code_ccy
      redis = KlineDB.redis
      market = Market.find "#{currency.code}#{Currency.fiats.first.code_ccy}"
      key = "peatio:#{market.id}:k:60"
      last_hour = 23.hours.since(Time.at ts)

      if redis.llen(key) > 0
        from = JSON.parse(redis.lindex(key, 0)).first
        offset = (last_hour.to_i - from) / 60.minutes
        point = JSON.parse redis.lindex(key, offset)
        last_hour_close_price = point[4]

        [amount*last_hour_close_price, amount, last_hour_close_price]
      else
        []
      end
    else
      [amount, amount, 1]
    end
  end

  def collect_stats(ts)
    trade_users = {}
    Market.all.each do |market|
      trade_users[market.id] = Worker::TradeStats.new(market).get_point(ts, 1440)
    end

    asset_stats = {}
    Currency.all.each do |currency|
      stat = Worker::WalletStats.new(currency).get_point(ts, 1440)
      asset_stats[currency.code] = asset_value(ts, currency, stat[3])
    end

    { trade_users:  trade_users,
      asset_stats:  asset_stats }
  end
end
