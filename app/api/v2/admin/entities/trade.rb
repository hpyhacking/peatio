# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Admin
      module Entities
        class Trade < API::V2::Entities::Trade
          unexpose(:side)
          unexpose(:order_id)

          expose(
            :maker_order_id,
            documentation: {
              type: String,
              desc: 'Trade maker order id.'
            }
          )

          expose(
            :taker_order_id,
            documentation: {
              type: String,
              desc: 'Trade taker order id.'
            }
          )

          expose(
            :maker_uid,
            documentation: {
              type: String,
              desc: 'Trade maker member uid.'
            }
          ) do |trade|
              trade.maker.uid
          end

          expose(
            :taker_uid,
            documentation: {
              type: String,
              desc: 'Trade taker member uid.'
            }
          ) do |trade|
            trade.taker.uid
          end
        end
      end
    end
  end
end
