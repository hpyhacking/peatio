module Jobs
  module Cron
    class Ticker
      def self.process
        @tickers = {}
        @cache_tickers = {}
        Market.active.each do |market|
          service = TickersService[market]
          ticker = service.ticker
          @tickers[market.id] = ticker
          @cache_tickers[market.id] = format_ticker ticker
        end
        Rails.logger.info { "Publish tickers: #{@tickers}" }
        Rails.cache.write(:markets_tickers, @cache_tickers)
        ::AMQP::Queue.enqueue_event('public', 'global', 'tickers', @tickers)
        sleep 5
      end

      def self.format_ticker(ticker)
        permitted_keys = %i[low high open last volume amount
                            avg_price price_change_percent]

        { at: ticker[:at],
          ticker: ticker }
      end
    end
  end
end
