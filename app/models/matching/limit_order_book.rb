module Matching
  class LimitOrderBook

    attr :side

    def initialize(side)
      @side   = side.to_sym
      @orders = RBTree.new
    end

    def add(order)
      @orders[order.price] ||= PriceLevel.new(order.price)
      @orders[order.price].add order
    end

    def remove(order)
      @orders[order.price].remove order
    end

    def dump
      orders = {}
      @orders.keys.each {|k| orders[k] = @orders[k].dump }
      orders
    end

  end
end
