# encoding: UTF-8
# frozen_string_literal: true

# People exchange commodities in markets. Each market focuses on certain
# commodity pair `{A, B}`. By convention, we call people exchange A for B
# *sellers* who submit *ask* orders, and people exchange B for A *buyers*
# who submit *bid* orders.
#
# ID of market is always in the form "#{B}#{A}". For example, in 'btcusd'
# market, the commodity pair is `{btc, usd}`. Sellers sell out _btc_ for
# _usd_, buyers buy in _btc_ with _usd_. _btc_ is the `base_unit`, while
# _usd_ is the `quote_unit`.
#
# Given market BTCUSD.
# Ask/Base currency/unit = BTC.
# Bid/Quote currency/unit = USD.

class Market < ApplicationRecord

  # == Constants ============================================================

  # Since we use decimal with 16 digits fractional part for storing numbers in DB
  # sum of multipliers fractional parts must not be greater then 16.
  # In the worst situation we have 3 multipliers (price * amount * fee).
  # For fee we define static precision - 6. See TradingFee::FEE_PRECISION.
  # So 10 left for amount and price precision.
  DB_DECIMAL_PRECISION = 16
  FUNDS_PRECISION = 10
  TOP_POSITION = 1

  STATES = %w[enabled disabled hidden locked sale presale].freeze
  # enabled - user can view and trade.
  # disabled - none can trade, user can't view.
  # hidden - user can't view but can trade.
  # locked - user can view but can't trade.
  # sale - user can't view but can trade with market orders.
  # presale - user can't view and trade. Admin can trade.

  # == Attributes ===========================================================

  attr_readonly :base_unit, :quote_unit

  # base_currency & quote_currency is preferred names instead of legacy
  # base_unit & quote_unit.
  # For avoiding DB migration and config we use alias as temporary solution.
  alias_attribute :base_currency, :base_unit
  alias_attribute :quote_currency, :quote_unit

  # == Extensions ===========================================================

  serialize :data, JSON unless Rails.configuration.database_support_json

  include Helpers::ReorderPosition

  # == Relationships ========================================================

  has_one :base, class_name: 'Currency', foreign_key: :id, primary_key: :base_unit
  has_one :quote, class_name: 'Currency', foreign_key: :id, primary_key: :quote_unit
  belongs_to :engine, required: true

  has_many :trading_fees, dependent: :delete_all

  # == Validations ==========================================================

  validate do
    if quote_currency == base_currency
      errors.add(:quote_currency, 'duplicates base currency')
    end
  end

  validate on: :create do
    if ENV['MAX_MARKETS'].present? && Market.count >= ENV['MAX_MARKETS'].to_i
      errors.add(:max, 'Market limit has been reached')
    end

    if Market.where(base_currency: quote_currency, quote_currency: base_currency).present? ||
       Market.where(base_currency: base_currency, quote_currency: quote_currency).present?
      errors.add(:base, "#{base_currency.upcase}, #{quote_currency.upcase} market already exists")
    end
  end

  validates :id, uniqueness: { case_sensitive: false }, presence: true

  validates :base_currency, :quote_currency, presence: true

  validates :min_price, :max_price, precision: { less_than_or_eq_to: ->(m) { m.price_precision } }

  validates :min_amount, precision: { less_than_or_eq_to: ->(m) { m.amount_precision } }

  validates :position,
            presence: true,
            numericality: { greater_than_or_equal_to: TOP_POSITION, only_integer: true }

  validates :amount_precision,
            :price_precision,
            numericality: { greater_than_or_equal_to: 0, only_integer: true }

  validates :price_precision,
            numericality: {
              less_than_or_equal_to: ->(_m) { FUNDS_PRECISION }
            }

  validates :amount_precision,
            numericality: {
              less_than_or_equal_to: ->(m) { FUNDS_PRECISION - m.price_precision }
            }

  validates :base_currency, :quote_currency, inclusion: { in: -> (_) { Currency.codes } }

  validates :min_price,
            presence: true,
            numericality: { greater_than_or_equal_to: ->(market){ market.min_price_by_precision } }
  validates :max_price,
            numericality: { allow_blank: true, greater_than_or_equal_to: ->(market){ market.min_price }},
            if: ->(market) { !market.max_price.zero? }

  validates :min_amount,
            presence: true,
            numericality: { greater_than_or_equal_to: ->(market){ market.min_amount_by_precision } }

  validates :state, inclusion: { in: STATES }

  # == Scopes ===============================================================

  scope :ordered, -> { order(position: :asc) }
  scope :active, -> { where(state: %i[enabled hidden]) }
  scope :enabled, -> { where(state: :enabled) }

  # == Callbacks ============================================================

  after_initialize :initialize_defaults, if: :new_record?
  before_validation(on: :create) { self.id = "#{base_currency}#{quote_currency}" }
  before_validation(on: :create) { self.position = Market.count + 1 unless position.present? }

  after_commit { AMQP::Queue.enqueue(:matching, action: 'new', market: id) }
  after_commit :wipe_cache
  after_create { insert_position(self) }

  before_update { update_position(self) if position_changed? }

  # == Instance Methods =====================================================

  def initialize_defaults
    self.data = {} if data.blank?
  end

  def wipe_cache
    Rails.cache.delete_matched("markets*")
  end

  def name
    "#{base_currency}/#{quote_currency}".upcase
  end

  def underscore_name
    "#{base_currency.upcase}_#{quote_currency.upcase}"
  end

  alias to_s name

  def round_amount(d)
    d.round(amount_precision, BigDecimal::ROUND_DOWN)
  end

  def round_price(d)
    d.round(price_precision, BigDecimal::ROUND_DOWN)
  end

  def unit_info
    { name: name, base_unit: base_currency, quote_unit: quote_currency }
  end

  # min_amount_by_precision - is the smallest positive number which could be
  # rounded to value greater then 0 with precision defined by
  # Market #amount_precision. So min_amount_by_precision is the smallest amount
  # of order/trade for current market.
  # E.g.
  #   market.amount_precision => 4
  #   min_amount_by_precision => 0.0001
  #
  #   market.amount_precision => 2
  #   min_amount_by_precision => 0.01
  #
  def min_amount_by_precision
    0.1.to_d**amount_precision
  end

  # See #min_amount_by_precision.
  def min_price_by_precision
    0.1.to_d**price_precision
  end

  def engine_name=(engine_name)
    self.engine = Engine.find_by(name: engine_name)
  end
end

# == Schema Information
# Schema version: 20200909083000
#
# Table name: markets
#
#  id               :string(20)       not null, primary key
#  base_unit        :string(10)       not null
#  quote_unit       :string(10)       not null
#  engine_id        :bigint           not null
#  amount_precision :integer          default(4), not null
#  price_precision  :integer          default(4), not null
#  min_price        :decimal(32, 16)  default(0.0), not null
#  max_price        :decimal(32, 16)  default(0.0), not null
#  min_amount       :decimal(32, 16)  default(0.0), not null
#  position         :integer          not null
#  data             :json
#  state            :string(32)       default("enabled"), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_markets_on_base_unit                 (base_unit)
#  index_markets_on_base_unit_and_quote_unit  (base_unit,quote_unit) UNIQUE
#  index_markets_on_engine_id                 (engine_id)
#  index_markets_on_position                  (position)
#  index_markets_on_quote_unit                (quote_unit)
#
