module Jobs
  module Cron
    class Ticker
      def self.process
        @tickers = {}
        Market.enabled.each do |market|
          service = TickersService[market]
          @tickers[market.id] = service.ticker
        end
        Rails.logger.info { "Publish tickers: #{@tickers}" }
        ::AMQP::Queue.enqueue_event('public', 'global', 'tickers', @tickers)
        sleep 5
      end
    end
  end
end
