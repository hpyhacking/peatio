require_relative 'constants'

module Matching
  class Executor

    def initialize(payload)
      @market = Market.find payload[:market_id]
      @ask    = OrderAsk.lock(true).find(payload[:ask_id])
      @bid    = OrderBid.lock(true).find(payload[:bid_id])
      @price  = BigDecimal.new payload[:strike_price]
      @volume = BigDecimal.new payload[:volume]
      @funds  = BigDecimal.new payload[:funds]
    end

    def execute!
      raise TradeExecutionError.new({ask: @ask, bid: @bid, price: @price, volume: @volume, funds: @funds}) unless valid?

      trade = create_and_strike_trade

      AMQPQueue.publish(
        :trade,
        trade.as_json,
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
                             price: @price, volume: @volume, funds: @funds,
                             currency: @market.id.to_sym, trend: trend)

        @bid.strike trade
        @ask.strike trade

        trade
      end
    end

    def valid?
      return false if @ask.ord_type == 'limit' && @ask.price > @price
      return false if @bid.ord_type == 'limit' && @bid.price < @price
      @funds > ZERO && [@ask.volume, @bid.volume].min >= @volume
    end

    def trend
      @price >= @market.latest_price ? 'up' : 'down'
    end

  end
end
