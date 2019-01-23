# encoding: UTF-8
# frozen_string_literal: true

class Global
  ZERO = '0.0'.to_d
  NOTHING_ARRAY = YAML::dump([])
  LIMIT = 80

  CACHE_EXPIRATION_TIME = {
    avg_h24_price: 5.minutes,
    h24_volume:    15.minutes
  }.freeze

  def initialize(market_id)
    @market_id = market_id
  end

  attr_accessor :market_id

  def self.[](market)
    if market.is_a? Market
      self.new(market.id)
    else
      self.new(market.to_s)
    end
  end

  # key(:suf1, :suf2) # => "peatio:btcusd:suf1:suf2"
  def key(*suffixes)
    [
      'peatio',
      market_id,
      suffixes
    ].join(':')
  end

  def time_key(interval)
    seconds = Time.now.to_i
    seconds - (seconds % interval)
  end

  def asks
    Rails.cache.read(key(:depth, :asks)) || []
  end

  def bids
    Rails.cache.read(key(:depth, :bids)) || []
  end

  def default_ticker
    { low: ZERO, high: ZERO, last: ZERO, volume: ZERO }
  end

  def ticker
    ticker           = Rails.cache.read(key(:ticker)) || default_ticker
    open             = Rails.cache.read(key(:ticker, :open)) || ticker[:last]
    best_buy_price   = bids.first && bids.first[0] || ZERO
    best_sell_price  = asks.first && asks.first[0] || ZERO
    avg_price        = avg_h24_price
    price_change_percent = change_ratio(open, ticker[:last])

    ticker.merge(
      at: at,
      open: open,
      volume: h24_volume,
      sell: best_sell_price,
      buy: best_buy_price,
      avg_price: avg_price,
      price_change_percent: price_change_percent
    )
  end

  def change_ratio(open, last)
    percent = open.zero? ? 0 : (last - open) / open * 100

    # Prepend sign. Show two digits after the decimal point. Append '%'.
    "#{'%+.2f' % percent}%"
  end

  def h24_volume
    cache_fetch(:h24_volume) do
      Trade.where(market_id: market_id).h24.sum(:volume) || ZERO
    end
  end

  # Average 24 hours price calculated using VWAP ratio.
  # For more info visit https://www.investopedia.com/terms/v/vwap.asp
  def avg_h24_price
    cache_fetch(:avg_h24_price) do
      Trade.with_market(market_id).h24.yield_self do |t|
        total_volume = t.sum(:volume)
        if total_volume.zero?
          ZERO
        else
          t.sum('price * volume') / total_volume
        end
      end
    end
  end

  def trades
    Rails.cache.read(key(:trades)) || []
  end

  def at
    @at ||= DateTime.now.to_i
  end

  def cache_fetch(method)
    Rails.cache.fetch(
      key(method),
      expires_in: CACHE_EXPIRATION_TIME[method]
    ) { yield if block_given? }
  end
end
