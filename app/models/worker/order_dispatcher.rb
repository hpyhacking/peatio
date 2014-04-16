module Worker
  class OrderDispatcher

    def new_order(payload)
      AMQPQueue.enqueue(:matching, action: 'submit', order: payload)
    end

    def cancel_order(payload)
      AMQPQueue.enqueue(:matching, action: 'cancel', order: payload)
    end

  end
end
