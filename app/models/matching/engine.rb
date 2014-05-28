module Matching
  class Engine

    attr :ask_limit_orders, :bid_limit_orders

    def initialize(market, options={})
      @market = market
      @ask_limit_orders = LimitOrderBook.new(:ask)
      @bid_limit_orders = LimitOrderBook.new(:bid)
    end

    def submit(order)
      book, counter_book = get_books order.type
      match order, counter_book
      book.add order unless order.filled?
    rescue
      Rails.logger.fatal "Failed to submit #{order}: #{$!}"
      Rails.logger.fatal $!.backtrace.join("\n")
    end

    def cancel(order)
      book, counter_book = get_books order.type
      book.remove order
    rescue
      Rails.logger.fatal "Failed to cancel #{order}: #{$!}"
      Rails.logger.fatal $!.backtrace.join("\n")
    end

    def dump
      { ask_limit_orders: @ask_limit_orders.dump,
        bid_limit_orders: @bid_limit_orders.dump }
    end

    private

    def get_books(type)
      case type
      when :ask
        [@ask_limit_orders, @bid_limit_orders]
      when :bid
        [@bid_limit_orders, @ask_limit_orders]
      end
    end

    def match(order, counter_book)
      return if order.filled?

      counter_order = counter_book.top
      return unless counter_order
      return unless order.crossed?(counter_order.price)

      # order is always the new coming order, so the trade price should
      # always follow the counter order (elder one)
      trade_price  = counter_order.price
      trade_volume = [order.volume, counter_order.volume].min

      counter_book.fill_top trade_volume
      order.fill trade_volume

      publish order, counter_order, trade_price, trade_volume

      match order, counter_book
    end

    def publish(order, counter_order, price, volume)
      ask, bid = order.type == :ask ? [order, counter_order] : [counter_order, order]

      Rails.logger.info "[#{@market.id}] new trade - #{ask} #{bid} price: #{price} volume: #{volume}"

      AMQPQueue.enqueue(
        :trade_executor,
        {market_id: @market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume},
        {persistent: false}
      )
    end

  end
end
