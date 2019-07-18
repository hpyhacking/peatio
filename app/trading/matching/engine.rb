# encoding: UTF-8
# frozen_string_literal: true

require_relative 'constants'

module Matching
  class Engine

    ORDER_SUBMIT_MAX_ATTEMPTS = 3

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

        price, volume, funds = trade
        validate_trade!(price, volume, funds)

        order.fill(price, volume, funds)
        opposite_book.fill_top(price, volume, funds)

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

    private

    def publish(order, counter_order, trade)
      ask, bid = order.type == :ask ? [order, counter_order] : [counter_order, order]

      # Rounding is forbidden in this step because it can cause difference
      # between amount/funds in DB and orderbook.
      price  = trade[0]
      volume = trade[1]
      funds  = trade[2]

      Rails.logger.info { "[#{@market.id}] new trade - ask: #{ask.label} bid: #{bid.label} price: #{price} volume: #{volume} funds: #{funds}" }

      @queue.enqueue(:trade_executor,
                     { market_id: @market.id,
                       ask_id: ask.id,
                       bid_id: bid.id,
                       strike_price: price,
                       volume: volume,
                       funds: funds },
                     { persistent: false })
    end

    def publish_cancel(order)
      @queue.enqueue(:order_processor,
                     { action: 'cancel', order: order.attributes },
                     { persistent: false })
    end

    def validate_trade!(price, volume, funds)
      message =
        if [price, volume, funds].any? { |d| d == ZERO }
          'price, volume or funds is equal to 0.'
        elsif price * volume != funds
          'price * volume != funds'
        elsif round(price * volume) != round(funds)
          'round(price * volume) != round(funds)'
        end

      return if message.blank?

      TradeStruct.new(price, volume, funds).tap do |t|
        raise TradeError.new(t, message)
      end
    end

    def round(d)
      d.round(Market::DB_DECIMAL_PRECISION, BigDecimal::ROUND_DOWN)
    end
  end
end
