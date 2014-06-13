require_relative 'constants'

module Matching
  class OrderBook

    attr :side

    def initialize(market, side, options={})
      @market = market
      @side   = side.to_sym
      @limit_orders = RBTree.new
      @market_orders = RBTree.new

      @broadcast = options.has_key?(:broadcast) ? options[:broadcast] : true
      broadcast(action: 'new', market: @market, side: @side)

      singleton = class<<self;self;end
      singleton.send :define_method, :limit_top, self.class.instance_method("#{@side}_limit_top")
    end

    def best_limit_price
      limit_top.try(:price)
    end

    def top
      @market_orders.empty? ? limit_top : @market_orders.first[1]
    end

    def fill_top(trade_price, trade_volume, trade_funds)
      order = top
      raise "No top order in empty book." unless order

      order.fill trade_price, trade_volume, trade_funds
      if order.filled?
        remove order
      else
        broadcast(action: 'update', order: order.attributes)
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
      raise InvalidOrderError, "volume is zero" if order.volume <= ZERO

      case order
      when LimitOrder
        @limit_orders[order.price] ||= PriceLevel.new(order.price)
        @limit_orders[order.price].add order
      when MarketOrder
        @market_orders[order.id] = order
      else
        raise ArgumentError, "Unknown order type"
      end

      broadcast(action: 'add', order: order.attributes)
    end

    def remove(order)
      case order
      when LimitOrder
        price_level = @limit_orders[order.price]
        price_level.remove order
        @limit_orders.delete(order.price) if price_level.empty?
      when MarketOrder
        @market_orders.delete order.id
      else
        raise ArgumentError, "Unknown order type"
      end

      broadcast(action: 'remove', order: order.attributes)
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

    def broadcast(data)
      return unless @broadcast
      Rails.logger.debug "orderbook broadcast: #{data.inspect}"
      AMQPQueue.enqueue(:slave_book, data, {persistent: false})
    end

  end
end
