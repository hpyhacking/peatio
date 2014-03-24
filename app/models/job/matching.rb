module Job
  class Matching
    include ::Matching

    @queue = :matching

    class <<self
      def perform(command, attrs)
        order = ::Matching::Order.new attrs
        send command, order
      end

      def submit(order)
        engine_for(order.market).submit!(order)
      end

      def cancel(order)
        engine_for(order.market).cancel!(order)
      end

      def engine_for(market)
        engines[market.id] ||= create_engine(market)
      end

      def create_engine(market)
        continue = ENV['FRESH'] == '1' ? false : true
        ::Matching::FIFOEngine.new(market, continue: continue)
      end

      def engines
        @engines ||= {}
      end

      def reset_engines
        @engines = {}
      end
    end

  end
end
