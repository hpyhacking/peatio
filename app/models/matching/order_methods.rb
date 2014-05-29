module Matching

  ZERO = 0.to_d

  class InvalidOrderError < StandardError; end

  module OrderMethods
    def fill(v)
      raise "Not enough volume to fill" if v > @volume
      @volume -= v
    end

    def filled?
      volume <= ZERO
    end
  end

end
