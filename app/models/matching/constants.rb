module Matching

  ZERO = 0.to_d unless defined?(ZERO)

  class DoubleSubmitError   < StandardError; end
  class InvalidOrderError   < StandardError; end
  class NotEnoughVolume     < StandardError; end
  class ExceedSumLimit      < StandardError; end
  class TradeExecutionError < StandardError; end

end
