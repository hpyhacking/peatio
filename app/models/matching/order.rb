module Matching

  class InvalidOrderError < StandardError; end

  class Order

    ZERO = 0.to_d

    attr :id, :timestamp, :type, :volume, :price

    def initialize(attrs)
      @id        = attrs[:id]
      @timestamp = attrs[:timestamp]
      @type      = attrs[:type].try(:to_sym)
      @volume    = attrs[:volume]
      @price     = attrs[:price]

      raise InvalidOrderError unless valid?(attrs)
    end

    def <=>(other)
      price_compare = price <=> other.price
      return price_compare unless price_compare == 0

      time_compare = timestamp <=> other.timestamp
      return time_compare unless time_compare == 0

      id <=> other.id
    end

    def equal?(other)
      id == other.id
    end

    private

    def valid?(attrs)
      return false unless [:ask, :bid].include?(type)
      id && timestamp && volume > ZERO && price > ZERO
    end

  end
end
