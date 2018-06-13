# encoding: UTF-8
# frozen_string_literal: true

module Worker
  class OrderProcessor
    def process(payload)
      case payload['action']
        when 'cancel'
          order = Order.find_by_id(payload.dig('order', 'id'))
          cancel(order) if order
      end
    end

  private

    def cancel(order)
      Ordering.new(order).cancel!
    rescue StandardError => e
      report_exception_to_screen(e)
    end
  end
end

