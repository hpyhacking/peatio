module Matching
  class PriceLevel

    attr :price

    def initialize(price)
      @price  = price
      @orders = []
    end

    def top
      @orders.first
    end

    def add(order)
      @orders << order
    end

    def remove(order)
      @orders.delete(order)
    end

    def dump
      @orders.map(&:label)
    end

  end
end
