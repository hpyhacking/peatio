module Job
  class Matching
    include ::Matching

    @queue = :matching

    class <<self
      def perform(attrs)
        order = ::Matching::Order.new attrs
        engine_for(order.market).submit!(order)
      end

      def engine_for(market)
        engines[market.id] ||= ::Matching::FIFOEngine.new(market)
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
