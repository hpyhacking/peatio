module Matching
  class TradeExecutionError < StandardError; end

  class Executor

    def initialize(market, ask, bid, price, volume)
      @market = market
      @ask    = OrderAsk.lock(true).find(ask.id)
      @bid    = OrderBid.lock(true).find(bid.id)
      @price  = price
      @volume = volume

      # TODO: validate ask/bid is able to execute with price/volume
    end

    def execute!
      raise TradeExecutionError unless valid?

      ActiveRecord::Base.transaction do
        lock_account!

        trade = Trade.create(ask_id: @ask.id, bid_id: @bid_id,
                             price: @price, volume: @volume,
                             currency: @market.id.to_sym, trend: trend)

        @bid.strike trade
        @ask.strike trade

        Global[@market].trigger_trade trade

        trade
      end
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
