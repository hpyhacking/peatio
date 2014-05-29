require_relative 'constants'

module Matching
  class LimitOrder
    attr :id, :timestamp, :type, :volume, :price, :market

    def initialize(attrs)
      @id        = attrs[:id]
      @timestamp = attrs[:timestamp]
      @type      = attrs[:type].try(:to_sym)
      @volume    = attrs[:volume].try(:to_d)
      @price     = attrs[:price].try(:to_d)
      @market    = Market.find attrs[:market]

      raise InvalidOrderError.new(attrs) unless valid?(attrs)
    end

    def trade_with(counter_order, counter_book)
      if counter_order.is_a?(LimitOrder)
        if crossed?(counter_order.price)
          [counter_order.price, [volume, counter_order.volume].min]
        end
      else
        trade_volume = [volume, counter_order.volume, counter_order.volume_limit(price)].min
        [price, trade_volume]
      end
    end

    def fill(trade_price, trade_volume)
      raise NotEnoughVolume if trade_volume > @volume
      @volume -= trade_volume
    end

    def filled?
      volume <= ZERO
    end

    def crossed?(price)
      if type == :ask
        price >= @price # if people offer price higher or equal than ask limit
      else
        price <= @price # if people offer price lower or equal than bid limit
      end
    end

    def label
      "%d/$%.02f/%.04f" % [id, price, volume]
    end

    def valid?(attrs)
      return false unless [:ask, :bid].include?(type)
      id && timestamp && market && volume > ZERO && price > ZERO
    end

  end
end
