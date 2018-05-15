# encoding: UTF-8
# frozen_string_literal: true

module APIv2
  module Entities
    class Trade < Base
      expose :id
      expose :price
      expose :volume
      expose :funds
      expose :market_id, as: :market
      expose :created_at, format_with: :iso8601

      expose :side do |trade, options|
        options[:side] || trade.side
      end

      expose :order_id, if: ->(trade, options){ options[:current_user] } do |trade, options|
        if trade.ask_member_id == options[:current_user].id
          trade.ask_id
        elsif trade.bid_member_id == options[:current_user].id
          trade.bid_id
        else
          nil
        end
      end

    end
  end
end
