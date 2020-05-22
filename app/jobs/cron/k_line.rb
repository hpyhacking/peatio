module Jobs
  module Cron
    class KLine
      def self.process
        Market.active.each do |market|
          ::KLineService::AVAILABLE_POINT_PERIODS.each do |period|
            service = ::KLineService[market.id, period]
            point = service.get_ohlc(order_by: :desc, limit: 1, offset: false).first
            next if point.blank?

            event_name = service.event_name(period)
            Rails.logger.info { "publishing #{point} #{event_name} stream for #{market.id}" }
            ::AMQP::Queue.enqueue_event('public', market.id,
                                        event_name, point)
          end
        end
        sleep 2
      end
    end
  end
end
