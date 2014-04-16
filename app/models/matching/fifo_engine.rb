module Matching
  class FIFOEngine

    def initialize(market, options={})
      @market = market
      @orderbook = OrderBook.new
    end

    def submit!(order)
      orderbook.submit(order)
      trade! while match?
    rescue
      puts "Fatal: Failed to submit #{order}: #{$!}"
      puts $!.backtrace.join("\n")
    end

    def cancel!(order)
      orderbook.cancel(order)
    rescue
      puts "Fatal: Failed to cancel #{order}: #{$!}"
      puts $!.backtrace.join("\n")
    end

    def match?
      return false unless orderbook.matchable?
      orderbook.highest_bid.price >= orderbook.lowest_ask.price
    end

    def trade
      ask, bid     = orderbook.pop_closest_pair!
      strike_price = get_strike_price ask, bid

      if ask.volume == bid.volume
        [ask, bid, strike_price, ask.volume]
      else
        small, large = [ask, bid].sort_by(&:volume)
        orderbook.submit get_left_partial(small, large)

        [ask, bid, strike_price, small.volume]
      end
    end

    def trade!
      ask, bid, strike_price, volume = trade
      puts "[#{@market.id}] new trade - #{ask} #{bid} strike_price: #{strike_price} volume: #{volume}"
      AMQPQueue.enqueue(:trade_executor, market_id: @market.id, ask_id: ask.id, bid_id: bid.id, strike_price: strike_price, volume: volume)
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
