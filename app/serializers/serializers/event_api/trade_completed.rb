# encoding: UTF-8
# frozen_string_literal: true

module Serializers
  module EventAPI
    class TradeCompleted
      def call(trade)
        { market:                trade.market.id,
          price:                 trade.price.to_s('F'),
          buyer_uid:             Member.uid(trade.bid_member_id),
          buyer_income_unit:     trade.market.ask_unit,
          buyer_income_amount:   trade.volume.to_s('F'),
          buyer_income_fee:      (trade.volume * trade.bid.fee).to_s('F'),
          buyer_outcome_unit:    trade.market.bid_unit,
          buyer_outcome_amount:  trade.funds.to_s('F'),
          buyer_outcome_fee:     '0.0',
          seller_uid:            Member.uid(trade.ask_member_id),
          seller_income_unit:    trade.market.bid_unit,
          seller_income_amount:  trade.funds.to_s('F'),
          seller_income_fee:     (trade.funds * trade.ask.fee).to_s('F'),
          seller_outcome_unit:   trade.market.ask_unit,
          seller_outcome_amount: trade.volume.to_s('F'),
          seller_outcome_fee:    '0.0',
          completed_at:          trade.created_at.iso8601 }
      end

      class << self
        def call(trade)
          new.call(trade)
        end
      end
    end
  end
end
