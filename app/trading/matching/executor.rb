# encoding: UTF-8
# frozen_string_literal: true

require_relative 'constants'

module Matching
  class Executor
    def initialize(payload)
      @payload = payload
      # NOTE: Run matching engine for disabled markets.
      @market  = Market.find(payload[:market_id])
      @price   = payload[:strike_price].to_d
      @volume  = payload[:volume].to_d
      @funds   = payload[:funds].to_d
    end

    def execute
      execute!
    rescue TradeExecutionError => e
      report_exception(e)
      false
    end

    def execute!
      create_trade_and_strike_orders
      publish_trade
      @trade
    end

  private

    def valid?
      return false if @ask.ord_type == 'limit' && @ask.price > @price
      return false if @bid.ord_type == 'limit' && @bid.price < @price
      return false unless @ask.state == Order::WAIT
      return false unless @bid.state == Order::WAIT
      @funds > ZERO && [@ask.volume, @bid.volume].min >= @volume
    end

    def trend
      @price >= @market.latest_price ? 'up' : 'down'
    end

    def create_trade_and_strike_orders
      ActiveRecord::Base.transaction do
        @ask = OrderAsk.lock.find(@payload[:ask_id])
        @bid = OrderBid.lock.find(@payload[:bid_id])

        unless valid?
          raise TradeExecutionError.new \
            ask: @ask, bid: @bid, price: @price, volume: @volume, funds: @funds
        end

        @trade = Trade.create! \
          ask:        @ask,
          ask_member: @ask.member,
          bid:        @bid,
          bid_member: @bid.member,
          price:      @price,
          volume:     @volume,
          funds:      @funds,
          market:     @market,
          trend:      trend

        @bid.strike @trade
        @ask.strike @trade
      end
    end

    def publish_trade
      AMQPQueue.publish :trade, @trade.as_json, {
        headers: {
          market:        @market.id,
          ask_member_id: @ask.member_id,
          bid_member_id: @bid.member_id
        }
      }
    end
  end
end
