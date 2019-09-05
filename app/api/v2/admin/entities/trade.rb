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
            :maker_order_email,
            documentation: {
              type: String,
              desc: 'Trade maker member email.'
            }
          ) { |trade| trade.maker.email }

          expose(
            :taker_order_email,
            documentation: {
              type: String,
              desc: 'Trade taker member email.'
            }
          ) { |trade| trade.taker.email }

          expose(
            :maker_uid,
            documentation: {
              type: String,
              desc: 'Trade maker member uid.'
            }
          ) { |trade| trade.maker.uid }

          expose(
            :taker_uid,
            documentation: {
              type: String,
              desc: 'Trade taker member uid.'
            }
          ) { |trade| trade.taker.uid }
        end
      end
    end
  end
end
