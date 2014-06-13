module Worker
  class OrderProcessor

    def process(payload, metadata, delivery_info)
      case payload['action']
      when 'cancel'
        order = Order.find payload['order']['id']
        Ordering.new(order).cancel(true)
      else
        raise ArgumentError, "Unrecogonized action: #{payload['action']}"
      end
    end

  end
end
