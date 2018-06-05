# encoding: UTF-8
# frozen_string_literal: true

module Services
  module HealthChecker
    LIVENESS_CHECKS = %i[check_db check_redis check_rabbitmq].freeze
    READINESS_CHECKS = %i[check_db].freeze

    class << self
      def alive?
        check! LIVENESS_CHECKS
      rescue StandardError => e
        report_exception_to_screen(e)
        false
      end

      def ready?
        check! READINESS_CHECKS
      rescue StandardError => e
        report_exception_to_screen(e)
        false
      end

      private

      def check!(checks)
        checks.all? { |m| send(m) }
      end

      def check_db
        Market.count
        Market.connected?
      end

      def check_redis
        redis = Rails.cache.instance_variable_get(:@data)
        redis.ping == 'PONG'
      end

      def check_rabbitmq
        Bunny.run(AMQPConfig.connect) { |c| c.connected? }
      end
    end
  end
end
