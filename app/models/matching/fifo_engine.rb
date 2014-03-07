module Matching
  class FIFOEngine

    def initialize(market)
      @market    = market
      @orderbook = OrderBook.new
    end

    def submit(order)
      @orderbook.submit(order)
    end

    def submit_and_run!(order)
      submit(order)
      trade! while match?
    end

    def match?
      return false unless @orderbook.matchable?
      @orderbook.highest_bid.price >= @orderbook.lowest_ask.price
    end

    def trade!
      ask, bid = @orderbook.pop_closest_pair!
      strike_price = get_strike_price ask, bid

      executor = if ask.volume == bid.volume
                   Executor.new(@market, ask, bid, strike_price, ask.volume)
                 else
                   raise NotImplementedError
                 end

      trade = executor.execute!
      Global[@market].trigger_trade trade
    end

    private

    # TODO: should we settle strike price based on last trade price?
    def get_strike_price(ask, bid)
      [ask, bid].sort_by(&:timestamp).first.price
    end

  end
end
