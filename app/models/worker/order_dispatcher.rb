module Worker
  class OrderDispatcher

    def process(order_attrs)
      AMQPQueue.enqueue(:matching, action: 'submit', order: order_attrs)
    end

  end
end
