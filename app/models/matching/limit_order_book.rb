module Matching
  class LimitOrderBook

    attr :side

    def initialize(side)
      @side   = side.to_sym
      @orders = RBTree.new

      singleton = class<<self;self;end
      singleton.send :define_method, :top, self.class.instance_method("#{@side}_top")
    end

    def fill_top(volume)
      order = top
      raise "No top order in empty book." unless order
      order.volume == volume ? remove(order) : order.fill(volume)
    end

    def add(order)
      @orders[order.price] ||= PriceLevel.new(order.price)
      @orders[order.price].add order
    end

    def remove(order)
      price_level = @orders[order.price]
      price_level.remove order
      @orders.delete(order.price) if price_level.empty?
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
