module Job
  class Matching
    include ::Matching

    @queue = :matching

    class <<self
      def perform(order)
        market = Market.find(order[:market])
        market.submit(order)
      end
    end

  end
end
