# encoding: UTF-8
# frozen_string_literal: true

class Currency < ApplicationRecord

  # == Constants ============================================================

  TOP_POSITION = 1
  STATES = %w[enabled disabled hidden].freeze
  # enabled - user can deposit and withdraw.
  # disabled - none can view, deposit and withdraw.
  # hidden - user can't view, but can deposit and withdraw.

  # == Attributes ===========================================================

  attr_readonly :id,
                :type

  # Code is aliased to id because it's more user-friendly primary key.
  # It's preferred to use code where this attributes are equal.
  alias_attribute :code, :id

  # == Extensions ===========================================================

  include Helpers::ReorderPosition

  # == Relationships ========================================================

  has_and_belongs_to_many :wallets
  has_many :blockchain_currencies
  has_one :default_network, class_name: :BlockchainCurrency, primary_key: :default_network_id, foreign_key: :id

  # == Validations ==========================================================

  validate on: :create do
    if ENV['MAX_CURRENCIES'].present? && Currency.count >= ENV['MAX_CURRENCIES'].to_i
      errors.add(:max, 'Currency limit has been reached')
    end
  end

  validates :code, presence: true, uniqueness: { case_sensitive: false }

  validates :position,
            presence: true,
            numericality: { greater_than_or_equal_to: TOP_POSITION, only_integer: true }

  validates :type, inclusion: { in: ->(_) { Currency.types.map(&:to_s) } }

  validates :precision, numericality: { greater_than_or_equal_to: 0 }

  validates :status, inclusion: { in: STATES }

  # == Scopes ===============================================================

  scope :visible, -> { where(status: :enabled) }
  scope :active, -> { where(status: %i[enabled hidden]) }
  scope :ordered, -> { order(position: :asc) }
  scope :coins, -> { where(type: :coin) }
  scope :fiats, -> { where(type: :fiat) }
  # This scope select all currencies without parent_id, which means that they are not tokens
  # and where currency type is coin
  scope :coins_without_tokens, -> { where(type: :coin).includes(:blockchain_currencies).where(blockchain_currencies: { parent_id: nil }).distinct }

  # == Callbacks ============================================================

  after_create do
    insert_position(self)
  end

  before_validation { self.code = code.downcase }
  before_validation(on: :create) { self.position = Currency.count + 1 unless position.present? }

  before_update { update_position(self) if position_changed? }

  after_commit :wipe_cache

  # == Class Methods ========================================================

  # NOTE: type column reserved for STI
  self.inheritance_column = nil

  class << self
    def codes(options = {})
      pluck(:id).yield_self do |downcase_codes|
        case
        when options.fetch(:bothcase, false)
          downcase_codes + downcase_codes.map(&:upcase)
        when options.fetch(:upcase, false)
          downcase_codes.map(&:upcase)
        else
          downcase_codes
        end
      end
    end

    def types
      %i[fiat coin].freeze
    end
  end

  # == Instance Methods =====================================================

  types.each { |t| define_method("#{t}?") { type == t.to_s } }

  def wipe_cache
    Rails.cache.delete_matched("currencies*")
  end

  # Allows to dynamically check value of id/code:
  #
  #   id.btc? # true if code equals to "btc".
  #   code.eth? # true if code equals to "eth".
  def id
    super&.inquiry
  end

  def update_price
    market = Market.find_by(base_unit: id, quote_unit: Peatio::App.config.platform_currency)
    ticker = Trade.market_ticker_from_influx(market.symbol) if market.present?
    currency_price = ticker.present? ? ticker[:vwap].to_d : self.price

    update_attribute(:price, currency_price)
  end

  def get_price
    if price.blank? || price.zero?
      raise "Price for currency #{id} is unknown"
    else
      price
    end
  end

  def dependent_markets
    Market.where('base_unit = ? OR quote_unit = ?', id, id)
  end
end

# == Schema Information
# Schema version: 20210803124131
#
# Table name: currencies
#
#  id                 :string(10)       not null, primary key
#  name               :string(255)
#  description        :text(65535)
#  homepage           :string(255)
#  type               :string(30)       default("coin"), not null
#  default_network_id :bigint
#  status             :string(32)       default("enabled"), not null
#  position           :integer          not null
#  precision          :integer          default(8), not null
#  icon_url           :string(255)
#  price              :decimal(32, 16)  default(1.0), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_currencies_on_position  (position)
#
