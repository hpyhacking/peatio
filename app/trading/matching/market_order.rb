# encoding: UTF-8
# frozen_string_literal: true

require_relative 'constants'

module Matching
  class MarketOrder < BaseOrder

    attr_reader :locked

    def initialize(attrs)
      super
      @locked = attrs[:locked].to_d

      raise OrderError.new(self, 'Order is not valid') unless valid?(attrs)
    end

    def trade_with(counter_order, _counter_book)
      if counter_order.is_a?(MarketOrder)
        raise MarketOrderbookError.new(order, 'market order in orderbook detected')
      end

      trade_price  = counter_order.price
      trade_volume = [volume, counter_order.volume].min
      trade_funds  = trade_price * trade_volume

      # If buy order is out of locked. Which means that order can't fulfill in
      # current price point because locked run out.
      return if bid? && trade_funds > locked

      [trade_price, trade_volume, trade_funds]
    end

    def fill(_trade_price, trade_volume, trade_funds)
      raise NotEnoughVolume if trade_volume > @volume
      @volume -= trade_volume

      funds = type == :ask ? trade_volume : trade_funds
      raise ExceedSumLimit if funds > @locked
      @locked -= funds
    end

    def filled?
      volume <= ZERO || locked <= ZERO
    end

    def label
      "%d/%s" % [id, volume.to_s('F')]
    end

    def valid?(attrs)
      type.in?(%i[ask bid]) && \
        attrs[:price].blank? && \
        id.present? && \
        timestamp.present? && \
        market.present? && \
        locked > ZERO
    end

    def attributes
      { id:        @id,
        timestamp: @timestamp,
        type:      @type,
        locked:    @locked,
        volume:    @volume,
        market:    @market,
        ord_type:  'market' }
    end
  end
end
