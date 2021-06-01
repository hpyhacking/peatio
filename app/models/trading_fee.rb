# encoding: UTF-8
# frozen_string_literal: true

# A trading fee schedule is a complete listing of maker and taker fees.
#
# E.g
# +-----------+---------+---------+---------+---------------------+---------------------+
# | market_id |  group  |  maker  |  taker  |     created_at      |      updated_at     |
# +-----------+---------+---------+---------+---------------------+---------------------+
# |   any     | any     | 0.0012  | 0.0012  | 2019-07-31 13:41:00 | 2019-07-31 13:41:00 |
# |   any     | vip-0   | 0.0011  | 0.0011  | 2019-07-31 13:41:00 | 2019-07-31 13:41:00 |
# | btcusd    | any     | 0.0011  | 0.0011  | 2019-07-31 13:41:00 | 2019-07-31 13:41:00 |
# | btcusd    | vip-0   | 0.001   | 0.001   | 2019-07-31 13:41:00 | 2019-07-31 13:41:00 |
# | btcusd    | vip-1   | 0.0009  | 0.001   | 2019-07-31 13:41:00 | 2019-07-31 13:41:00 |
# | btcusd    | vip-2   | 0.0007  | 0.0009  | 2019-07-31 13:41:00 | 2019-07-31 13:41:00 |
# +-----------+---------+---------+---------+---------------------+---------------------+
#
# for member with unspecified group and market
#   maker fee will be 0.12%;
#   taker fee will be 0.12%;
# for member with group vip-0 and with unspecified market
#   maker fee will be 0.11%;
#   taker fee will be 0.11%;
# for member with market btcusd and with unspecified group
#   maker fee will be 0.11%;
#   taker fee will be 0.11%;
# for member with group vip-0 and for market btcusd
#   maker fee will be 0.1%;
#   taker fee will be 0.1%;
# for member with group vip-1 and for market btcusd
#   maker fee will be 0.09%;
#   taker fee will be 0.1%;
# for member with group vip-2 and for market btcusd
#   maker fee will be 0.07%;
#   taker fee will be 0.09%;
#
class TradingFee < ApplicationRecord
  # == Constants ============================================================

  # For fee we define static precision - 4.
  FEE_PRECISION = 6

  MIN_FEE = 0
  MAX_FEE = 0.5

  # Default value for group name and market_id in TradingFee table;
  ANY = 'any'

  # == Attributes ===========================================================

  # == Extensions ===========================================================

  # == Relationships ========================================================

  belongs_to :market, ->(trading_fee) { where(type: trading_fee.market_type) }, foreign_key: :market_id, primary_key: :symbol, optional: true

  # == Validations ==========================================================

  validates :group,
            presence: true,
            uniqueness: { scope: :market_id }

  validates :maker,
            :taker,
            presence: true,
            numericality: { greater_than_or_equal_to: MIN_FEE,
                            less_than_or_equal_to: MAX_FEE }

  validates :market_id,
            presence: true,
            inclusion: { in: ->(_fs) { Market.pluck(:symbol).append(ANY) } }

  validates :market_type,
            presence: true,
            inclusion: { in: ->(_fs) { Market::TYPES } }

  validates :maker, :taker, precision: { less_than_or_eq_to: FEE_PRECISION }

  # == Scopes ===============================================================

  scope :spot, -> { where(market_type: 'spot') }
  scope :qe, -> { where(market_type: 'qe') }

  # == Callbacks ============================================================

  before_create { self.group = self.group.strip.downcase }
  after_commit :wipe_cache

  # == Class Methods ========================================================

  class << self

    # Get trading fee for specific order that based on member group and market_id.
    # TradingFee record selected with the next priorities:
    #  1. both group and market_id match
    #  2. group match
    #  3. market_id match
    #  4. both group and market_id are 'any'
    #  5. default (zero fees)
    def for(group:, market_id:, market_type: Market::DEFAULT_TYPE)
      TradingFee
        .where(market_id: [market_id, ANY], market_type: [market_type, ANY], group: [group, ANY])
        .max_by { |fs| fs.weight } || TradingFee.new
    end
  end

  # == Instance Methods =====================================================

  # Trading fee suitability expressed in weight.
  # Trading fee with the greatest weight selected.
  # Group match has greater weight then market_id match.
  # E.g. Order for member with group 'vip-0' and market_id 'btcusd'
  # (group == 'vip-0' && market_id == 'btcusd') >
  # (group == 'vip-0' && market_id == 'any') >
  # (group == 'any' && market_id == 'btcusd') >
  # (group == 'any' && market_id == 'any')
  def weight
    (group == 'any' ? 0 : 10) + (market_id == 'any' ? 0 : 1)
  end

  def wipe_cache
    Rails.cache.delete_matched("trading_fees*")
  end
end

# == Schema Information
# Schema version: 20210609094033
#
# Table name: trading_fees
#
#  id          :bigint           not null, primary key
#  market_id   :string(20)       default("any"), not null
#  market_type :string(255)      default("spot"), not null
#  group       :string(32)       default("any"), not null
#  maker       :decimal(7, 6)    default(0.0), not null
#  taker       :decimal(7, 6)    default(0.0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_trading_fees_on_group                                (group)
#  index_trading_fees_on_market_id_and_market_type            (market_id,market_type)
#  index_trading_fees_on_market_id_and_market_type_and_group  (market_id,market_type,group) UNIQUE
#
