# encoding: UTF-8
# frozen_string_literal: true

module BelongsToMarket
  extend ActiveSupport::Concern

  included do
    belongs_to :market, required: true
    scope :with_market, -> (market) { where(market_id: Market === market ? market.id : market) }
  end
end
