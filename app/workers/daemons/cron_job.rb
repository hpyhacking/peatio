# frozen_string_literal: true

# K-line point is represented as array of 5 numbers:
# [timestamp, open_price, max_price, min_price, last_price, period_volume]

module Workers
  module Daemons
    class CronJob < Base
      JOBS = [Jobs::Cron::KLine, Jobs::Cron::Ticker].freeze

      def run
        JOBS.map { |j| Thread.new { process(j) } }.map(&:join)
      end

      def process(service)
        service.process while running
      end
    end
  end
end
