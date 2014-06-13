class Global
  ZERO = '0.0'.to_d
  NOTHING_ARRAY = YAML::dump([])
  LIMIT = 80

  def initialize(currency)
    @currency = currency
  end

  def channel
    "market-#{@currency}-global"
  end

  attr_accessor :currency

  def self.[](market)
    if market.is_a? Market
      self.new(market.id)
    else
      self.new(market)
    end
  end

  def key(key, interval=5)
    seconds  = Time.now.to_i
    time_key = seconds - (seconds % interval)
    "#{@currency}-#{key}-#{time_key}"
  end

  def asks
    Rails.cache.read("peatio:#{currency}:depth:asks") || []
  end

  def bids
    Rails.cache.read("peatio:#{currency}:depth:bids") || []
  end

  def default_ticker
    {low: ZERO, high: ZERO, last: ZERO, volume: ZERO}
  end

  def ticker
    ticker          = Rails.cache.read("peatio:#{currency}:ticker") || default_ticker
    best_buy_price  = bids.first && bids.first[0] || ZERO
    best_sell_price = asks.first && asks.first[0] || ZERO

    ticker.merge({
      at: at,
      sell: best_sell_price,
      buy: best_buy_price
    })
  end

  def trades
    Rails.cache.read("peatio:#{currency}:trades") || []
  end

  def since_trades(id)
    trades ||= Trade.with_currency(currency).where("id > ?", id).order(:id).limit(LIMIT)
    trades.map(&:for_global)
  end

  def price
    Rails.cache.fetch key('price1', 300) do
      Trade.with_currency(currency)
        .select("id, price, sum(volume) as volume, trend, currency, max(created_at) as created_at")
        .where("created_at > ?", 24.to_i.hours.ago).order(:id)
        .group("ROUND(UNIX_TIMESTAMP(created_at)/(5 * 60))") # group by 5 minutes
        .order('max(created_at) ASC')
        .map(&:for_global)
    end
  end

  def trigger_ticker
    data = {:ticker => ticker, :asks => asks, :bids => bids}
    Pusher.trigger_async(channel, "update", data)
  end

  def trigger_trades(trades)
    {trades: trades}
    Pusher.trigger_async(channel, "trades", trades: trades)
  end

  def at
    @at ||= DateTime.now.to_i
  end
end
