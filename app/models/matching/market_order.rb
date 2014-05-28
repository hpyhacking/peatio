module Matching

  class MarketOrder

    attr :id, :timestamp, :type, :volume, :guard_price, :market

    def initialize(attrs)
      raise InvalidOrderError.new(attrs) unless valid?(attrs)

      @id          = attrs[:id]
      @timestamp   = attrs[:timestamp]
      @type        = attrs[:type].try(:to_sym)
      @guard_price = attrs[:guard_price]
      @volume      = attrs[:volume].try(:to_d)
      @market      = Market.find attrs[:market]
    end

    def valid?(attrs)
      return false unless [:ask, :bid].include?(type)
      return false if attrs[:price].present? # should have no limit price
      id && timestamp && market && volume > ZERO && guard_price > ZERO
    end

  end

end
