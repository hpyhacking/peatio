module Matching

  class InvalidOrderError < StandardError; end

  class Order

    ZERO = 0.to_d

    attr :id, :timestamp, :type, :volume, :target, :price

    def initialize(attrs)
      @id        = attrs[:id]
      @timestamp = attrs[:timestamp]
      @type      = attrs[:type].try(:to_sym)
      @volume    = attrs[:volume].try(:to_d)
      @target    = attrs[:target].try(:to_d)
      @price     = attrs[:price].try(:to_d)

      raise InvalidOrderError unless valid?(attrs)
    end

    def <=>(other)
      price_compare = price <=> other.price
      return price_compare unless price_compare == 0

      timestamp <=> other.timestamp
    end

    private

    def valid?(attrs)
      return false unless [:ask, :bid].include?(type)
      id && timestamp && volume > ZERO && target > ZERO && price > ZERO
    end

  end
end
