class Global
  ZERO = '0.0'.to_d
  NOTHING_ARRAY = YAML::dump([])
  LIMIT = 80

  class << self
    def channel
      "market-global"
    end

    def trigger(event, data)
      Pusher.trigger_async(channel, event, data)
    end

    def daemon_statuses
      Rails.cache.fetch('peatio:daemons:statuses', expires_in: 3.minute) do
        Daemons::Rails::Monitoring.statuses
      end
    end
  end

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
    "peatio:#{@currency}:#{key}:#{time_key}"
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
    ticker           = Rails.cache.read("peatio:#{currency}:ticker") || default_ticker
    open = Rails.cache.read("peatio:#{currency}:ticker:open") || ticker[:last]
    best_buy_price   = bids.first && bids.first[0] || ZERO
    best_sell_price  = asks.first && asks.first[0] || ZERO

    ticker.merge({
      open: open,
      volume: h24_volume,
      sell: best_sell_price,
      buy: best_buy_price,
      at: at
    })
  end

  def h24_volume
    Rails.cache.fetch key('h24_volume', 5), expires_in: 24.hours do
      Trade.with_currency(currency).h24.sum(:volume) || ZERO
    end
  end

  def trades
    Rails.cache.read("peatio:#{currency}:trades") || []
  end

  def trigger_orderbook
    data = {asks: asks, bids: bids}
    Pusher.trigger_async(channel, "update", data)
  end

  def trigger_trades(trades)
    Pusher.trigger_async(channel, "trades", trades: trades)
  end

  def at
    @at ||= DateTime.now.to_i
  end
end
