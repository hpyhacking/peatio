module Matching
  class FIFOEngine

    def initialize(market, options={})
      @market = market
      @logger = options.delete(:logger) || Rails.logger

      initialize_orderbook(options[:continue])
    end

    def submit!(order)
      orderbook.submit(order)
      trade! while match?
    rescue
      @logger.fatal "Failed to submit #{order}: #{$!}"
      @logger.debug $!.backtrace.join("\n")
    end

    def cancel!(order)
      orderbook.cancel(order)
    rescue
      @logger.fatal "Failed to cancel #{order}: #{$!}"
      @logger.debug $!.backtrace.join("\n")
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
      @logger.info "[#{@market.id}] new trade - #{ask} #{bid} strike_price: #{strike_price} volume: #{volume}"
      Executor.new(@market, ask, bid, strike_price, volume).execute!
    end

    private

    def initialize_orderbook(continue)
      @orderbook = OrderBook.new

      if continue
        ::Order.active.with_currency(@market.id).order('id asc').each do |order|
          order = ::Matching::Order.new order.to_matching_attributes
          submit! order
        end
      end
    end

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
