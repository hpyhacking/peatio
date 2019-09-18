# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Daemons
    class Base
      class << self; attr_accessor :sleep_time end

      attr_accessor :running
      attr_reader :logger

      def initialize
        @running = true
        @logger = Rails.logger
      end

      def stop
        @running = false
      end

      def run
        while running
          begin
            process
          rescue ScriptError => e
            raise e if is_db_connection_error?(e)

            report_exception(e)
          end
          wait
        end
      end

      def process
        method_not_implemented
      end

      def wait
        Kernel.sleep self.class.sleep_time
      end

      def is_db_connection_error?(exception)
        exception.is_a?(Mysql2::Error::ConnectionError) || exception.cause.is_a?(Mysql2::Error)
      end
    end
  end
end
