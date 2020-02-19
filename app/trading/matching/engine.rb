# encoding: UTF-8
# frozen_string_literal: true

require_relative 'constants'

module Matching
  class Engine

    ORDER_SUBMIT_MAX_ATTEMPTS = 3
    MIN_INCREMENT_COUNT_TO_SNAPSHOT = 20
    MIN_PERIOD_TO_SNAPSHOT = 10.second
    MAX_PERIOD_TO_SNAPSHOT = 60.second

    attr :orderbook, :mode, :queue
    attr_accessor :initializing, :snapshot_time, :increment_count, :sequence_number
    delegate :ask_orders, :bid_orders, to: :orderbook

    def initialize(market, options={})
      @market    = market
      @orderbook = OrderBookManager.new(market.id, on_change: method(:publish_increment))
      @initializing = true
      @sequence_number = 1
      @increment_count = 0
      @snapshot_time = Time.now
      # Engine is able to run in different mode:
      # dryrun: do the match, do not publish the trades
      # run:    do the match, publish the trades (default)
      shift_gears(options[:mode] || :run)
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
        @queue = AMQP::Queue
      else
        raise "Unrecognized mode: #{mode}"
      end

      @mode = mode
    end

    def submit(order)
      attempt ||= 1
      match(order)
    rescue StandardError => e
      Rails.logger.error "Failed to submit order #{order.label}. Attempt #{attempt}."
      report_exception(e)
      if attempt < ORDER_SUBMIT_MAX_ATTEMPTS
        Rails.logger.error "Retrying to submit order #{order.label}."
        attempt += 1
        retry
      else
        Rails.logger.error "Cancelling order #{order.label}."
        publish_cancel(order)
      end
    end

    def match(order)
      book, opposite_book = orderbook.get_books(order.type)

      loop do
        # If order is fulfilled we stop matching.
        break if order.filled?

        # If opposite orderbook is empty:
        # - add order to orderbook in case of limit order;
        # - publish message with cancel action to order processor in case of market order.
        if opposite_book.top.blank?
          order.is_a?(LimitOrder) ? book.add(order) : publish_cancel(order)
          break
        end

        opposite_order = opposite_book.top
        trade = order.trade_with(opposite_order, opposite_book)

        # If order doesn't match with best order opposite order:
        # - add order to orderbook in case of limit order;
        # - publish message with cancel action to order processor in case of market order.
        if trade.blank?
          order.is_a?(LimitOrder) ? book.add(order) : publish_cancel(order)
          break
        end

        price, amount, total = trade
        validate_trade!(price, amount, total)

        order.fill(price, amount, total)
        opposite_book.fill_top(price, amount, total)

        # Publish message to trade_executor with matched trade.
        publish(order, opposite_order, trade)

        # NOTE: Legacy peatio was designed in the way that there is orderbook
        # for both limit and market orders.
        # We are using MarketOrderbookError for averting this behaviour.
        # Market order is either match directly or it's cancelled.
        # This error and it's usage should be dropped with market type
        # orderbook removing.
      rescue MarketOrderbookError => e
        report_exception(e)
        cancel(e.order)
      end
    end

    def cancel(order)
      book, _counter_book = orderbook.get_books(order.type)
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

    def publish_snapshot
      @snapshot_time = Time.now
      ::AMQP::Queue.enqueue_event("public", @market.id, "ob-snap", {
        "asks" => ask_orders.limit_orders.map{|k,v| [k.to_s, v.map(&:volume).sum.to_s]}[0..300],
        "bids" => bid_orders.limit_orders.map{|k,v| [k.to_s, v.map(&:volume).sum.to_s]}.reverse[0..300],
        "sequence" => @sequence_number,
      })
    end

    def publish_increment(market, side, price, amount)
      return if @initializing

      # Publish snapshot if:
      # increment_count < 20 and last snapshot time > 1 min
      # increment_count > 20 and last snapshot time > 10 second
      if @increment_count < MIN_INCREMENT_COUNT_TO_SNAPSHOT && @snapshot_time <= Time.now - MAX_PERIOD_TO_SNAPSHOT
        publish_snapshot
        @increment_count = 0
      elsif @increment_count >= MIN_INCREMENT_COUNT_TO_SNAPSHOT && @snapshot_time < Time.now - MIN_PERIOD_TO_SNAPSHOT
        publish_snapshot
        @increment_count = 0
      end
      @increment_count += 1
      @sequence_number += 1
      ::AMQP::Queue.enqueue_event("public", market, "ob-inc", {
        "#{side}s" => [price.to_s, amount.to_s],
        "sequence" => @sequence_number,
      })
    end

    private

    def publish(order, counter_order, trade)
      maker_order, taker_order = order.id < counter_order.id ? [order, counter_order] : [counter_order, order]
      # Rounding is forbidden in this step because it can cause difference
      # between amount/total in DB and orderbook.
      price  = trade[0]
      amount = trade[1]
      total  = trade[2]

      Rails.logger.info { "[#{@market.id}] new trade - maker_order: #{maker_order.label} taker_order: #{taker_order.label} price: #{price} amount: #{amount} total: #{total}" }

      @queue.enqueue(:trade_executor,
                     { action: 'execute',
                       trade: {
                         market_id: @market.id,
                         maker_order_id: maker_order.id,
                         taker_order_id: taker_order.id,
                         strike_price: price,
                         amount: amount,
                         total: total } },
                     { persistent: false })
    end

    def publish_cancel(order)
      @queue.enqueue(:trade_executor,
                     { action: 'cancel', order: order.attributes },
                     { persistent: false })
    end

    def validate_trade!(price, amount, total)
      message =
        if [price, amount, total].any? { |d| d == ZERO }
          'price, amount or total is equal to 0.'
        elsif price * amount != total
          'price * amount != total'
        elsif round(price * amount) != round(total)
          'round(price * amount) != round(total)'
        end

      return if message.blank?

      TradeStruct.new(price, amount, total).tap do |t|
        raise TradeError.new(t, message)
      end
    end

    def round(d)
      d.round(Market::DB_DECIMAL_PRECISION, BigDecimal::ROUND_DOWN)
    end
  end
end
