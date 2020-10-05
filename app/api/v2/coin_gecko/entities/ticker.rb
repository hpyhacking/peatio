# frozen_string_literal: true

module API
  module V2
    module CoinGecko
      module Entities
        class Ticker < API::V2::Entities::Base
          expose(
            :ticker_id,
              documentation: {
               type: String,
               desc: 'Identifier of a ticker with delimiter to separate base/target, eg. BTC_ETH.'
              }
          ) do |ticker|
            ticker[:market].underscore_name
          end

          expose(
            :base_currency,
            documentation: {
              type: String,
              desc: 'Symbol/currency code of base pair, eg. BTC.'
            }
          ) do |ticker|
            ticker[:market][:base_unit].upcase
          end

          expose(
            :target_currency,
            documentation: {
              type: String,
              desc: 'Symbol/currency code of target pair, eg. ETH.'
            }
          ) do |ticker|
            ticker[:market][:quote_unit].upcase
          end

          expose(
            :last_price,
            documentation: {
              type: BigDecimal,
              desc: 'Last transacted price of base currency based on given target currency.'
            }
          ) do |ticker|
            ticker[:last]
          end

          expose(
            :base_volume,
            documentation: {
              type: BigDecimal,
              desc: '24 hour trading volume in base pair volume.'
            }
          ) do |ticker|
            ticker[:amount]
          end

          expose(
            :target_volume,
            documentation: {
              type: BigDecimal,
              desc: '24 hour trading volume in base pair volume.'
            }
          ) do |ticker|
            ticker[:volume]
          end

          expose(
            :bid,
            documentation: {
              type: BigDecimal,
              desc: 'Current highest bid price.'
            }
          ) do |ticker|
            OrderBid.get_depth(ticker[:market].id).flatten.first.to_d
          end

          expose(
            :ask,
            documentation: {
              type: BigDecimal,
              desc: 'Current lowest ask price.'
            }
          ) do |ticker|
            OrderAsk.get_depth(ticker[:market].id).flatten.first.to_d
          end

          expose(
            :high,
            documentation: {
              type: BigDecimal,
              desc: 'The highest trade price during last 24 hours (0.0 if no trades executed during last 24 hours).'
            }
          ) do |ticker|
            ticker[:high]
          end

          expose(
            :low,
            documentation: {
              type: BigDecimal,
              desc: 'The lowest trade price during last 24 hours (0.0 if no trades executed during last 24 hours).'
            }
          ) do |ticker|
            ticker[:low]
          end
        end
      end
    end
  end
end
