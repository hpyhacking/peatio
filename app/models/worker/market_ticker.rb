module Worker
  class MarketTicker

    FRESH_TRADES = 80

    def initialize
      @tickers = {}
      @trades  = {}

      Market.all.each do |market|
        initialize_market_data market
      end
    end

    def process(payload, metadata, delivery_info)
      trade = Trade.new payload
      update_ticker trade
      update_latest_trades trade
    end

    def update_ticker(trade)
      ticker = @tickers[trade.market.id]
      ticker[:low]     = trade.price if trade.price < ticker[:low]
      ticker[:high]    = trade.price if trade.price > ticker[:high]
      ticker[:last]    = trade.price
      ticker[:volume] += trade.volume

      Rails.cache.write "peatio:#{trade.market.id}:ticker", ticker
    end

    def update_latest_trades(trade)
      trades = @trades[trade.market.id]
      trades.unshift(trade.for_global).pop

      Rails.cache.write "peatio:#{trade.market.id}:trades", trades
    end

    def initialize_market_data(market)
      trades = Trade.with_currency(market)
      @trades[market.id] = trades.order('id desc').limit(FRESH_TRADES).map(&:for_global)
      @tickers[market.id] = {
        low:    trades.h24.minimum(:price) || ::Trade::ZERO,
        high:   trades.h24.maximum(:price) || ::Trade::ZERO,
        last:   trades.last.try(:price)    || ::Trade::ZERO,
        volume: trades.h24.sum(:volume)    || ::Trade::ZERO
      }
    end

  end
end
