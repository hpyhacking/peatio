module Matching
  class LimitOrderBook

    attr :side

    def initialize(side)
      @side   = side.to_sym
      @orders = RBTree.new

      singleton = class<<self;self;end
      singleton.send :define_method, :top, self.class.instance_method("#{@side}_top")
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

    private

    def ask_top # lowest price wins
      return if @orders.empty?
      price, level = @orders.first
      level.top
    end

    def bid_top # highest price wins
      return if @orders.empty?
      price, level = @orders.last
      level.top
    end

  end
end
