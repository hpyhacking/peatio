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

      trade = create_and_strike_trade

      AMQPQueue.publish(
        :trade,
        { id: trade.id },
        { headers: {
            market: @market.id,
            ask_member_id: @ask.member_id,
            bid_member_id: @bid.member_id
          }
        }
      )

      trade
    end

    private

    def create_and_strike_trade
      ActiveRecord::Base.transaction do
        trade = Trade.create(ask_id: @ask.id, ask_member_id: @ask.member_id,
                             bid_id: @bid.id, bid_member_id: @bid.member_id,
                             price: @price, volume: @volume,
                             currency: @market.id.to_sym, trend: trend)

        @bid.strike trade
        @ask.strike trade

        trade
      end
    end

    def valid?
      [@ask.volume, @bid.volume].min >= @volume &&
        @ask.price <= @price &&
        @bid.price >= @price
    end

    def trend
      @price >= @market.latest_price ? 'up' : 'down'
    end

  end
end
