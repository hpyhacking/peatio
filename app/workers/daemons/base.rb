# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module Daemons
    class Base
      class GetLockError < StandardError; end
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

      def lock(klass, timeout)
        res = ActiveRecord::Base.connection.exec_query("SELECT GET_LOCK('Peatio_#{klass}',#{timeout})")

        # response from this query will look like this [{"GET_LOCK(id,10)"=>1}]
        # returns 1 if the lock was obtained successfully, 0 if the attempt timed out
        if res.to_a[0].values[0] == 1
          begin
            yield
          rescue StandardError => e
            report_exception(e)
          ensure
            ActiveRecord::Base.connection.exec_query("SELECT RELEASE_LOCK('Peatio_#{klass}')")
          end
        else
          raise GetLockError, "Peatio_#{klass} is already running"
        end
      end
    end
  end
end
