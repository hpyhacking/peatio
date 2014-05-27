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

    def fill(v)
      raise "Not enough volume to fill" if v > @volume
      @volume -= v
    end

    def crossed?(price)
      if type == :ask
        price >= @price # if people offer price higher or equal than ask limit
      else
        price <= @price # if people offer price lower or equal than bid limit
      end
    end

    def <=>(other)
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
