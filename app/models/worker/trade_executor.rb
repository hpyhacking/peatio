module Worker
  class TradeExecutor

    def initialize
      @tickers = {}

      Market.all.each do |market|
        trades = Trade.with_currency(market)
        @tickers[market.id] = {
          low:    trades.h24.minimum(:price) || ::Trade::ZERO,
          high:   trades.h24.maximum(:price) || ::Trade::ZERO,
          last:   trades.last.try(:price)    || ::Trade::ZERO,
          volume: trades.h24.sum(:volume)    || ::Trade::ZERO
        }
      end
    end

    def process(payload, metadata, delivery_info)
      payload.symbolize_keys!
      trade = ::Matching::Executor.new(payload).execute!
      update_ticker trade
    end

    def update_ticker(trade)
      ticker = @tickers[trade.market.id]
      ticker[:low]     = trade.price if trade.price < ticker[:low]
      ticker[:high]    = trade.price if trade.price > ticker[:high]
      ticker[:last]    = trade.price
      ticker[:volume] += trade.volume

      cache_ticker(trade.market.id, ticker)
    end

    def cache_ticker(market, ticker)
      [:low, :high, :last, :volume].each do |k|
        Rails.cache.write "peatio:#{market}:ticker:#{k}",    ticker[k]
      end
    end

  end
end
