module Worker
  class OrderProcessor

    def initialize
      @cancel_queue = []
      create_cancel_thread
    end

    def process(payload, metadata, delivery_info)
      case payload['action']
      when 'cancel'
        unless check_and_cancel(payload['order'])
          @cancel_queue << payload['order']
        end
      else
        raise ArgumentError, "Unrecogonized action: #{payload['action']}"
      end
    end

    def check_and_cancel(attrs)
      order = Order.find attrs['id']
      if order.volume == attrs['volume'].to_d # all trades has been processed
        Ordering.new(order).cancel!
        puts "Order##{order.id} cancelled."
        true
      end
    rescue Ordering::CancelOrderError
      puts "Skipped: #{$!}"
      true
    end

    def create_cancel_thread
      Thread.new do
        loop do
          sleep 5

          queue = @cancel_queue
          @cancel_queue = []

          queue.each do |attrs|
            unless check_and_cancel(attrs)
              @cancel_queue << attrs
            end
          end
        end
      end
    end

  end
end
