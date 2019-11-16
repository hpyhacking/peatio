# encoding: UTF-8
# frozen_string_literal: true

require_relative 'constants'

module Matching
  class OrderBook

    attr :side

    def initialize(market, side, options={})
      @market = market
      @side   = side.to_sym
      @limit_orders = RBTree.new
      @market_orders = RBTree.new
      @on_change = options[:on_change]

      singleton = class<<self;self;end
      singleton.send :define_method, :limit_top, self.class.instance_method("#{@side}_limit_top")
    end

    def notify_change(market, side, price, amount=nil)
      return unless @on_change

      amount ||= yield
      @on_change.call(market, side, price, amount)
    rescue StandardError => e
      report_exception(e)
    end

    def best_limit_price
      limit_top.try(:price)
    end

    def top
      unless @market_orders.empty?
        order = @market_orders.first[1]
        raise MarketOrderbookError.new(order, 'market order in orderbook detected')
      end

      limit_top
    end

    def fill_top(trade_price, trade_volume, trade_funds)
      order = top
      raise "No top order in empty book." unless order

      order.fill trade_price, trade_volume, trade_funds
      if order.filled?
        remove order
      else
        notify_change(@market, @side, trade_price) { @limit_orders[trade_price]&.total }
      end
    end

    def find(order)
      case order
      when LimitOrder
        @limit_orders[order.price].find(order.id)
      when MarketOrder
        @market_orders[order.id]
      end
    end

    def add(order)
      raise OrderError.new(order, 'volume is less than or equal to zero') if order.volume <= ZERO

      case order
      when LimitOrder
        @limit_orders[order.price] ||= PriceLevel.new(order.price)
        @limit_orders[order.price].add order
        notify_change(@market, @side, order.price) { @limit_orders[order.price]&.total }
      when MarketOrder
        raise MarketOrderbookError.new(order, 'market order adding to orderbook detected')
      else
        raise ArgumentError, "Unknown order type"
      end
    end

    def remove(order)
      case order
      when LimitOrder
        updated_order = remove_limit_order(order)
        notify_change(@market, @side, order.price) { @limit_orders[order.price]&.total }
        return updated_order
      when MarketOrder
        remove_market_order(order)
      else
        raise ArgumentError, "Unknown order type"
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

    def remove_limit_order(order)
      price_level = @limit_orders[order.price]
      return unless price_level

      order = price_level.find order.id # so we can return fresh order
      return unless order

      price_level.remove order
      @limit_orders.delete(order.price) if price_level.empty?

      order
    end

    def remove_market_order(order)
      if order = @market_orders[order.id]
        @market_orders.delete order.id
        order
      end
    end

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
