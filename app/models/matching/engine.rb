module Matching
  class Engine

    attr :orderbook, :mode, :queue
    delegate :ask_orders, :bid_orders, to: :orderbook

    def initialize(market, options={})
      @market    = market
      @orderbook = OrderBookManager.new(market.id)

      # Engine is able to run in different mode:
      # dryrun: do the match, do not publish the trades
      # run:    do the match, publish the trades (default)
      shift_gears(options[:mode] || :run)
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
      if removed_order = book.remove(order)
        publish_cancel removed_order, "cancelled by user"
      else
        Rails.logger.warn "Cannot find order##{order.id} to cancel, skip."
      end
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

    def shift_gears(mode)
      case mode
      when :dryrun
        @queue = []
        class <<@queue
          def enqueue(*args)
            push args
          end
        end
      when :run
        @queue = AMQPQueue
      else
        raise "Unrecognized mode: #{mode}"
      end

      @mode = mode
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

      @queue.enqueue(
        :trade_executor,
        {market_id: @market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume, funds: funds},
        {persistent: false}
      )
    end

    def publish_cancel(order, reason)
      Rails.logger.info "[#{@market.id}] cancel order ##{order.id} - reason: #{reason}"
      @queue.enqueue(
        :order_processor,
        {action: 'cancel', order: order.attributes},
        {persistent: false}
      )
    end

  end
end
