require_relative 'constants'

module Matching
  class Executor

    def initialize(payload)
      @payload = payload
      @market  = Market.find payload[:market_id]
      @price   = BigDecimal.new payload[:strike_price]
      @volume  = BigDecimal.new payload[:volume]
      @funds   = BigDecimal.new payload[:funds]
    end

    def execute!
      retry_on_error(5) { create_trade_and_strike_orders }
      publish_trade
      @trade
    end

    private

    def valid?
      return false if @ask.ord_type == 'limit' && @ask.price > @price
      return false if @bid.ord_type == 'limit' && @bid.price < @price
      @funds > ZERO && [@ask.volume, @bid.volume].min >= @volume
    end

    def trend
      @price >= @market.latest_price ? 'up' : 'down'
    end

    # in worst condition, the method will run 1+retry_count times then fail
    def retry_on_error(retry_count, &block)
      block.call
    rescue ActiveRecord::StatementInvalid
      # cope with "Mysql2::Error: Deadlock found ..." exception
      if retry_count > 0
        sleep 0.2
        retry_count -= 1
        puts "Retry trade execution (#{retry_count} retry left) .."
        retry
      else
        puts "Failed to execute trade: #{@payload.inspect}"
        raise $!
      end
    end

    def create_trade_and_strike_orders
      ActiveRecord::Base.transaction do
        @ask = OrderAsk.lock(true).find(@payload[:ask_id])
        @bid = OrderBid.lock(true).find(@payload[:bid_id])

        raise TradeExecutionError.new({ask: @ask, bid: @bid, price: @price, volume: @volume, funds: @funds}) unless valid?

        @trade = Trade.create!(ask_id: @ask.id, ask_member_id: @ask.member_id,
                               bid_id: @bid.id, bid_member_id: @bid.member_id,
                               price: @price, volume: @volume, funds: @funds,
                               currency: @market.id.to_sym, trend: trend)

        @bid.strike @trade
        @ask.strike @trade
      end

      # TODO: temporary fix, can be removed after pusher -> polling refactoring
      if @trade.ask_member_id == @trade.bid_member_id
        @ask.hold_account.reload.trigger
        @bid.hold_account.reload.trigger
      end
    end

    def publish_trade
      AMQPQueue.publish(
        :trade,
        @trade.as_json,
        { headers: {
            market: @market.id,
            ask_member_id: @ask.member_id,
            bid_member_id: @bid.member_id
          }
        }
      )
    end

  end
end
