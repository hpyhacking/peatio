# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class OrderProcessor
    def initialize
      Order.where(state: ::Order::PENDING).find_each do |order|
        Order.submit(order.id)
      end
    end

    def process(payload)
      case payload['action']
      when 'submit'
        Order.submit(payload.dig('order', 'id'))
      when 'cancel'
        Order.cancel(payload.dig('order', 'id'))
      end
    rescue => e
      AMQPQueue.enqueue(:trade_error, e.message)
      report_exception_to_screen(e)
    end
  end
end
