module Matching

  class NoLimitOrderError < StandardError; end

  class OrderBook

    attr :side

    def initialize(side)
      @side   = side.to_sym
      @limit_orders = RBTree.new
      @market_orders = RBTree.new

      singleton = class<<self;self;end
      singleton.send :define_method, :limit_top, self.class.instance_method("#{@side}_limit_top")
    end

    def best_limit_price
      limit_top.try(:price)
    end

    def top
      @market_orders.empty? ? limit_top : @market_orders.first[1]
    end

    def fill_top(volume)
      order = top
      raise "No top order in empty book." unless order
      order.volume == volume ? remove(order) : order.fill(volume)
    end

    def add(order)
      case order
      when LimitOrder
        @limit_orders[order.price] ||= PriceLevel.new(order.price)
        @limit_orders[order.price].add order
      when MarketOrder
        # Reject incoming market order if there's no existing limit order in
        # book, so this book can always provide a best limit price.
        raise NoLimitOrderError if @limit_orders.empty?

        @market_orders[order.id] = order
      end
    end

    def remove(order)
      case order
      when LimitOrder
        price_level = @limit_orders[order.price]
        price_level.remove order
        @limit_orders.delete(order.price) if price_level.empty?
      when MarketOrder
        @market_orders.delete order.id
      end
    end

    def limit_orders
      orders = {}
      @limit_orders.keys.each {|k| orders[k] = @limit_orders[k].orders }
      orders
    end

    def market_orders
      @market_orders.values
    end

    private

    def ask_limit_top # lowest price wins
      return if @limit_orders.empty?
      price, level = @limit_orders.first
      level.top
    end

    def bid_limit_top # highest price wins
      return if @limit_orders.empty?
      price, level = @limit_orders.last
      level.top
    end

  end
end
