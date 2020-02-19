# encoding: UTF-8
# frozen_string_literal: true

module Workers
  module AMQP
    class OrderProcessor < Base
      def initialize
        Order.where(state: ::Order::PENDING).find_each do |order|
          Order.submit(order.id)
        rescue StandardError => e
          AMQPQueue.enqueue(:trade_error, e.message)
          report_exception_to_screen(e)

          raise e if is_db_connection_error?(e)
        end
      end

      def process(payload)
        case payload['action']
        when 'submit'
          Order.submit(payload.dig('order', 'id'))
        when 'cancel'
          Order.cancel(payload.dig('order', 'id'))
        end
      rescue StandardError => e
        ::AMQP::Queue.enqueue(:trade_error, e.message)
        report_exception_to_screen(e)

        raise e if is_db_connection_error?(e)
      end
    end
  end
end
