# encoding: UTF-8
# frozen_string_literal: true

module Matching

  # NOTE: Name is TradeStruct for not confusing it with ActiveRecord Trade model.
  # TODO: Use TradeStruct instead of trade_price, trade_volume, trade_funds.
  TradeStruct = Struct.new(:price, :amount, :total)

  ZERO = 0.to_d unless defined?(ZERO)

  Error = Class.new(StandardError)

  class OrderError < Error

    attr_reader :order

    def initialize(order, message=nil)
      @order = order
      super "#{message} (#{order.attributes})"
    end
  end

  class TradeError < Error

    attr_reader :trade

    def initialize(trade, message=nil)
      @trade = trade
      super "#{message} (#{trade})"
    end
  end

  # TODO: Use OrderError & TradeError instead of
  # NotEnoughVolume, ExceedSumLimit, TradeExecutionError.
  class NotEnoughVolume < Error; end
  class ExceedSumLimit < Error; end
  class MarketOrderbookError < OrderError; end

  class TradeExecutionError < Error
    attr_accessor :options

    def initialize(options = {})
      self.options = options
    end
  end
end
