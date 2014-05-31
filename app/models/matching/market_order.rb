require_relative 'constants'

module Matching
  class MarketOrder
    attr :id, :timestamp, :type, :volume, :locked, :market

    def initialize(attrs)
      @id          = attrs[:id]
      @timestamp   = attrs[:timestamp]
      @type        = attrs[:type].try(:to_sym)
      @locked      = attrs[:locked].try(:to_d)
      @volume      = attrs[:volume].try(:to_d)
      @market      = Market.find attrs[:market]

      raise ::Matching::InvalidOrderError.new(attrs) unless valid?(attrs)
    end

    def trade_with(counter_order, counter_book)
      if counter_order.is_a?(LimitOrder)
        trade_price  = counter_order.price
        trade_volume = [volume, volume_limit(trade_price), counter_order.volume].min
        [trade_price, trade_volume]
      elsif price = counter_book.best_limit_price
        trade_price  = price
        trade_volume = [volume, volume_limit(trade_price), counter_order.volume, counter_order.volume_limit(trade_price)].min
        [trade_price, trade_volume]
      end
    end

    def volume_limit(trade_price)
      type == :ask ? locked : locked/trade_price
    end

    def fill(trade_price, trade_volume)
      raise NotEnoughVolume if trade_volume > @volume
      @volume -= trade_volume

      sum = type == :ask ? trade_volume : trade_price*trade_volume
      raise ExceedSumLimit if sum > @locked
      @locked -= sum
    end

    def filled?
      volume <= ZERO || locked <= ZERO
    end

    def label
      "%d/%.04f" % [id, volume]
    end

    def valid?(attrs)
      return false unless [:ask, :bid].include?(type)
      return false if attrs[:price].present? # should have no limit price
      id && timestamp && market && volume > ZERO && locked > ZERO
    end

  end
end
