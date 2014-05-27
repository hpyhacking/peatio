module Matching
  class OrderBook

    attr :side

    def initialize(side)
      @side = side.to_sym
      @limit_orders = RBTree.new
    end

    def add(order)
      raise ArgumentError, "#{side} orderbook accept only #{side} order. Order: #{order.inspect}" if order.type != side

      case order.ord_type
      when 'limit'
        @limit_orders[order.price] ||= PriceLevel.new(order.price)
        @limit_orders[order.price].add order
      else
        raise ArgumentError, "Invalid ord_type. Order: #{order.inspect}"
      end
    end

    def remove(order)
      raise ArgumentError, "#{side} orderbook accept only #{side} order. Order: #{order.inspect}" if order.type != side

      case order.ord_type
      when 'limit'
        @limit_orders[order.price].remove order
      else
        raise ArgumentError, "Invalid ord_type. Order: #{order.inspect}"
      end
    end

    def dump
      limit_orders = {}
      @limit_orders.keys.each {|k| limit_orders[k] = @limit_orders[k].dump }
      { limit_orders: limit_orders }
    end

  end
end
