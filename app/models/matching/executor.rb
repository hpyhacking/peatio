module Matching
  class TradeExecutionError < StandardError; end

  class Executor

    def initialize(payload)
      @market = Market.find payload[:market_id]
      @ask    = OrderAsk.lock(true).find(payload[:ask_id])
      @bid    = OrderBid.lock(true).find(payload[:bid_id])
      @price  = BigDecimal.new payload[:strike_price]
      @volume = BigDecimal.new payload[:volume]
    end

    def execute!
      raise TradeExecutionError.new({ask: @ask, bid: @bid, price: @price, volume: @volume}) unless valid?

      trade = Trade.create(ask_id: @ask.id, ask_member_id: @ask.member_id,
                           bid_id: @bid.id, bid_member_id: @bid.member_id,
                           price: @price, volume: @volume,
                           currency: @market.id.to_sym, trend: trend)

      ActiveRecord::Base.transaction do
        lock_account!

        @bid.strike trade
        @ask.strike trade
      end

      AMQPQueue.publish(
        :octopus,
        {market: @market.id, id: trade.id, ask_id: @ask.id, bid_id: @bid.id},
        {routing_key: "trade.#{@market.id}.#{@ask.member_id}.#{@bid.member_id}"}
      )

      trade
    end

    private

    def valid?
      [@ask.volume, @bid.volume].min >= @volume &&
        @ask.price <= @price &&
        @bid.price >= @price
    end

    def lock_account!
      @bid.hold_account.lock!
      @ask.hold_account.lock!

      @bid.expect_account.lock!
      @ask.expect_account.lock!
    end

    def trend
      @price >= @market.latest_price ? 'up' : 'down'
    end

  end
end
