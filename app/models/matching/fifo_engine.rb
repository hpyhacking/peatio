module Matching
  class FIFOEngine

    def initialize(market)
      @market    = market
      @orderbook = OrderBook.new
    end

    def submit!(order)
      orderbook.submit(order)
      trade! while match?
    end

    def match?
      return false unless orderbook.matchable?
      orderbook.highest_bid.price >= orderbook.lowest_ask.price
    end

    def trade!
      ask, bid = orderbook.pop_closest_pair!
      executor = ask.volume == bid.volume ? full_match_executor(ask, bid) : partial_match_executor(ask, bid)
      executor.execute!
    end

    private

    def orderbook
      @orderbook
    end

    # TODO: should we settle strike price based on last trade price?
    def get_strike_price(ask, bid)
      # sort by id instead of timestamp, because the timestamp comes from
      # created_at in db whose precision is limited to seconds.
      [ask, bid].sort_by(&:id).first.price
    end

    def full_match_executor(ask, bid)
      Executor.new(@market, ask, bid, get_strike_price(ask, bid), ask.volume)
    end

    def partial_match_executor(ask, bid)
      small, large = [ask, bid].sort_by(&:volume)
      orderbook.submit get_left_partial(small, large)

      Executor.new(@market, ask, bid, get_strike_price(ask, bid), small.volume)
    end

    def get_left_partial(small, large)
      ::Matching::Order.new(
        id:        large.id,
        type:      large.type,
        price:     large.price,
        market:    large.market,
        timestamp: large.timestamp,
        volume:    large.volume - small.volume
      )
    end

  end
end
