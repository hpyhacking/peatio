module Matching
  class Engine

    attr :orderbook
    delegate :ask_orders, :bid_orders, to: :orderbook

    def initialize(market)
      @market        = market
      @orderbook     = OrderBookManager.new(market.id)
    end

    def submit(order)
      book, counter_book = orderbook.get_books order.type
      match order, counter_book
      add_or_cancel order, book
    rescue
      Rails.logger.fatal "Failed to submit order #{order.label}: #{$!}"
      Rails.logger.fatal $!.backtrace.join("\n")
    end

    def cancel(order)
      book, counter_book = orderbook.get_books order.type
      order = book.remove order
      publish_cancel order, "cancelled by user"
    rescue
      Rails.logger.fatal "Failed to cancel order #{order.label}: #{$!}"
      Rails.logger.fatal $!.backtrace.join("\n")
    end

    def limit_orders
      { ask: ask_orders.limit_orders,
        bid: bid_orders.limit_orders }
    end

    def market_orders
      { ask: ask_orders.market_orders,
        bid: bid_orders.market_orders }
    end

    private

    def match(order, counter_book)
      return if order.filled?

      counter_order = counter_book.top
      return unless counter_order

      if trade = order.trade_with(counter_order, counter_book)
        counter_book.fill_top *trade
        order.fill *trade

        publish order, counter_order, trade

        match order, counter_book
      end
    end

    def add_or_cancel(order, book)
      return if order.filled?
      order.is_a?(LimitOrder) ?
        book.add(order) : publish_cancel(order, "fill or kill market order")
    end

    def publish(order, counter_order, trade)
      ask, bid = order.type == :ask ? [order, counter_order] : [counter_order, order]

      price  = @market.fix_number_precision :bid, trade[0]
      volume = @market.fix_number_precision :ask, trade[1]
      funds  = trade[2]

      Rails.logger.info "[#{@market.id}] new trade - ask: #{ask.label} bid: #{bid.label} price: #{price} volume: #{volume} funds: #{funds}"

      AMQPQueue.enqueue(
        :trade_executor,
        {market_id: @market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume, funds: funds},
        {persistent: false}
      )
    end

    def publish_cancel(order, reason)
      Rails.logger.info "[#{@market.id}] cancel order ##{order.id} - reason: #{reason}"
      AMQPQueue.enqueue(
        :order_processor,
        {action: 'cancel', order: order.attributes},
        {persistent: false}
      )
    end

  end
end
