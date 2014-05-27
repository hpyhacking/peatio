module Matching

  class InvalidOrderError < StandardError; end

  class Order

    ZERO = 0.to_d

    attr :id, :timestamp, :type, :ord_type, :volume, :price, :market

    def initialize(attrs)
      attrs.symbolize_keys!

      @id        = attrs[:id]
      @timestamp = attrs[:timestamp]
      @type      = attrs[:type].try(:to_sym)
      @ord_type  = attrs[:ord_type]
      @volume    = attrs[:volume].try(:to_d)
      @price     = attrs[:price].try(:to_d)
      @market    = Market.find attrs[:market]

      raise InvalidOrderError.new(attrs) unless valid?(attrs)
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

    def to_s
      "#{@type}:#{id}/#{volume}/#{price}"
    end

    def label
      "%d/$%.02f/%.04f" % [id, price, volume]
    end

    private

    def valid?(attrs)
      return false unless [:ask, :bid].include?(type)
      id && timestamp && market && volume > ZERO && price > ZERO
    end

  end
end
