# encoding: UTF-8
# frozen_string_literal: true

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
      match(order, counter_book)
      add_or_cancel(order, book)
    rescue => e
      Rails.logger.error { "Failed to submit order #{order.label}." }
      report_exception(e)
    end

    def cancel(order)
      book, counter_book = orderbook.get_books(order.type)
      book.remove(order)
      publish_cancel(order)
    rescue => e
      Rails.logger.error { "Failed to cancel order #{order.label}." }
      report_exception(e)
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

    def match(order, counter_book, attempt_number = 1, maximum_attempts = 3)
      return if attempt_number >= maximum_attempts
      match_implementation(order, counter_book)
    rescue StandardError => e
      report_exception(e) if attempt_number == 1
      match(order, counter_book, attempt_number + 1, maximum_attempts)
    end

    def match_implementation(order, counter_book)
      return if order.filled?
      return unless (counter_order = counter_book.top)

      if trade = order.trade_with(counter_order, counter_book)
        counter_book.fill_top(*trade)
        order.fill(*trade)
        publish(order, counter_order, trade)
        match_implementation(order, counter_book)
      end
    end

    def add_or_cancel(order, book)
      return if order.filled?
      order.is_a?(LimitOrder) ? book.add(order) : publish_cancel(order)
    end

    def publish(order, counter_order, trade)
      ask, bid = order.type == :ask ? [order, counter_order] : [counter_order, order]

      price  = @market.fix_number_precision :bid, trade[0]
      volume = @market.fix_number_precision :ask, trade[1]
      funds  = trade[2]

      Rails.logger.info { "[#{@market.id}] new trade - ask: #{ask.label} bid: #{bid.label} price: #{price} volume: #{volume} funds: #{funds}" }

      @queue.enqueue(
        :trade_executor,
        {market_id: @market.id, ask_id: ask.id, bid_id: bid.id, strike_price: price, volume: volume, funds: funds},
        {persistent: false}
      )
    end

    def publish_cancel(order)
      @queue.enqueue \
        :order_processor,
        { action: 'cancel', order: order.attributes },
        { persistent: false }
    end
  end
end
