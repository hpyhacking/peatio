# encoding: UTF-8
# frozen_string_literal: true

module Serializers
  module EventAPI
    class TradeCompleted
      def call(trade)
        {
          id: trade.id,
          market: trade.market.id,
          price: trade.price.to_s('F'),
          amount: trade.amount.to_s('F'),
          completed_at: trade.created_at.iso8601
        }.merge(maker_attributes(trade), taker_attributes(trade))
      end

      class << self
        def call(trade)
          new.call(trade)
        end
      end

      def maker_attributes(trade)
        if trade.maker_order.side == 'sell'
          {
            maker_uid: trade.maker.uid,
            maker_income_unit: trade.market.quote_unit,
            maker_income_amount: trade.total.to_s('F'),
            maker_income_fee: (trade.total * trade.order_fee(trade.maker_order)).to_s('F'),
            maker_outcome_unit: trade.market.base_unit,
            maker_outcome_amount: trade.amount.to_s('F'),
            maker_outcome_fee: '0.0'
          }
        else
          {
            maker_uid: trade.maker.uid,
            maker_income_unit: trade.market.base_unit,
            maker_income_amount: trade.amount.to_s('F'),
            maker_income_fee: (trade.amount * trade.order_fee(trade.maker_order)).to_s('F'),
            maker_outcome_unit: trade.market.quote_unit,
            maker_outcome_amount: trade.total.to_s('F'),
            maker_outcome_fee: '0.0'
          }
        end
      end

      def taker_attributes(trade)
        if trade.maker_order.side == 'sell'
          {
            taker_uid: trade.taker.uid,
            taker_income_unit: trade.market.base_unit,
            taker_income_amount: trade.amount.to_s('F'),
            taker_income_fee: (trade.amount * trade.order_fee(trade.taker_order)).to_s('F'),
            taker_outcome_unit: trade.market.quote_unit,
            taker_outcome_amount: trade.total.to_s('F'),
            taker_outcome_fee: '0.0'
          }
        else
          {
            taker_uid: trade.taker.uid,
            taker_income_unit: trade.market.quote_unit,
            taker_income_amount: trade.total.to_s('F'),
            taker_income_fee: (trade.total * trade.order_fee(trade.taker_order)).to_s('F'),
            taker_outcome_unit: trade.market.base_unit,
            taker_outcome_amount: trade.amount.to_s('F'),
            taker_outcome_fee: '0.0'
          }
        end
      end
    end
  end
end
