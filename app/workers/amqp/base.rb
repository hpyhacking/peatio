# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class Base
      def is_db_connection_error?(exception)
        exception.is_a?(Mysql2::Error::ConnectionError) || exception.cause.is_a?(Mysql2::Error)
      end
    end
  end
end
