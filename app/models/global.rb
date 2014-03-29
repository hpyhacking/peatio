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
    Rails.cache.fetch key('asks') do
      OrderAsk.active.with_currency(currency).matching_rule.position
    end
  end

  def bids
    Rails.cache.fetch key('bids') do
      OrderBid.active.with_currency(currency).matching_rule.position
    end
  end

  def ticker
    Rails.cache.fetch key('ticker') do
      Trade.with_currency(currency).tap do |query|
        return {
          at:     at,
          low:    query.h24.minimum(:price) || ZERO,
          high:   query.h24.maximum(:price) || ZERO,
          last:   query.last.try(:price)    || ZERO,
          volume: query.h24.sum(:volume)    || ZERO,
          buy:    bids.first && bids.first[0] || ZERO,
          sell:   asks.first && asks.first[0] || ZERO
        }
      end
    end
  end

  def trades
    Rails.cache.fetch key('trades') do
      @trades = Trade.with_currency(currency).last(LIMIT).reverse
      @trades.map { |t| format_trade(t) }
    end
  end

  def since_trades(id)
    trades ||= Trade.with_currency(currency).where("id > ?", id).order(:id).limit(LIMIT)
    trades.map do |t| format_trade(t) end
  end

  def price
    Rails.cache.fetch key('price1', 300) do
      Trade.with_currency(currency)
        .select("id, price, sum(volume) as volume, trend, currency, max(created_at) as created_at")
        .where("created_at > ?", 24.to_i.hours.ago).order(:id)
        .group("ROUND(UNIX_TIMESTAMP(created_at)/(5 * 60))") # group by 5 minutes
        .order('max(created_at) ASC')
        .map {|t| format_trade(t)}
    end
  end

  def format_trade(t)
    { :date => t.created_at.to_i,
      :price => t.price.to_s || ZERO,
      :amount => t.volume.to_s || ZERO,
      :tid => t.id,
      :type => t.trend ? 'sell' : 'buy' }
  end

  def trigger_trade(t)
    data = {:trades => [format_trade(t)]}
    Pusher.trigger_async(channel, "trades", data)
  end

  def trigger
    data = {:ticker => ticker, :asks => asks, :bids => bids}
    Pusher.trigger_async(channel, "update", data)
  end

  def at
    @at ||= DateTime.now.to_i
  end
end
