module Matching

  ZERO = 0.to_d

  class InvalidOrderError   < StandardError; end
  class NotEnoughVolume     < StandardError; end
  class ExceedSumLimit      < StandardError; end
  class NoLimitOrderError   < StandardError; end
  class TradeExecutionError < StandardError; end

end
