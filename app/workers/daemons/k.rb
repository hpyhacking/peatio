# frozen_string_literal: true

# K-line point is represented as array of 5 numbers:
# [timestamp, open_price, max_price, min_price, last_price, period_volume]

module Workers
  module Daemons
    class K < Base

      self.sleep_time = 1

      def process
        # NOTE: Turn off ticker & k-line updates for disabled markets.
        Market.enabled.each do |market|
          KLineService::HUMANIZED_POINT_PERIODS.values.each do |period|
            Peatio::InfluxDB.client(epoch: 's').query("SELECT * FROM candles_#{period} WHERE market='#{market.id}' GROUP BY market ORDER BY DESC LIMIT 1") do |_name, _tags, points|
              points.map do |point|
                result = [point['time'], point['open'], point['high'], point['low'], point['close'], point['volume']]
                logger.info { "publishing #{result} #{event_name(period)} stream for #{market.id}" }
                Peatio::Ranger::Events.publish('public', market.id,
                                           event_name(period), result)
              end
            end
          end
        end
      end

      # Example of event_name 'kline-1m'.
      def event_name(period)
        "kline-#{period}"
      end
    end
  end
end
