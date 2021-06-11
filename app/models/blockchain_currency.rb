# frozen_string_literal: true

class BlockchainCurrency < ApplicationRecord

  # == Constants ============================================================
  DB_DECIMAL_PRECISION = 16
  OPTIONS_ATTRIBUTES = %i[erc20_contract_address gas_limit].freeze

  STATES = %w[enabled disabled hidden].freeze
  # enabled - user can deposit and withdraw.
  # disabled - none can view, deposit and withdraw.
  # hidden - user can't view, but can deposit and withdraw.

  # == Attributes ===========================================================

  attr_readonly :base_factor

  # == Extensions ===========================================================

  serialize :options, JSON unless Rails.configuration.database_support_json

  OPTIONS_ATTRIBUTES.each do |attribute|
    define_method attribute do
      self.options[attribute.to_s]
    end

    define_method "#{attribute}=".to_sym do |value|
      self.options = options.merge(attribute.to_s => value)
    end
  end

  # == Relationships ========================================================

  belongs_to :currency, required: true
  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  # == Validations ==========================================================

  validates :blockchain_key,
            inclusion: { in: ->(_) { Blockchain.pluck(:key).map(&:to_s) } },
            if: -> { currency.coin? }

  validates :options, length: { maximum: 1000 }
  validates :base_factor, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  validates :blockchain_key, uniqueness: { scope: :currency_id }

  validates :deposit_fee,
            :min_deposit_amount,
            :min_collection_amount,
            :withdraw_fee,
            :min_withdraw_amount,
            :withdraw_limit_24h,
            :withdraw_limit_72h,
            numericality: { greater_than_or_equal_to: 0 }

  validates :status, inclusion: { in: STATES }

  # == Scopes ===============================================================

  scope :visible, -> { where(status: :enabled) }
  scope :active, -> { where(status: %i[enabled hidden]) }
  scope :deposit_enabled, -> { where(deposit_enabled: true) }
  scope :withdrawal_enabled, -> { where(withdrawal_enabled: true) }

  # == Callbacks ============================================================

  after_initialize :initialize_defaults

  before_validation { self.deposit_fee = 0 unless currency.fiat? }
  before_validation { self.blockchain_key = currency.parent.blockchain_key if currency.token? && blockchain_key.blank? }

  before_validation do
    self.erc20_contract_address = erc20_contract_address.try(:downcase) if erc20_contract_address.present?
  end

  after_create do
    update_fees if auto_update_fees_enabled && currency.coin?
  end

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
  delegate :explorer_transaction, :explorer_address, :blockchain_api, :description, :warning, :protocol, to: :blockchain

  def initialize_defaults
    self.options = {} if options.blank?
  end

  def blockchain
    Rails.cache.fetch("#{currency_id}_blockchain", expires_in: 60) { Blockchain.find_by(key: blockchain_key) }
  end

  # subunit (or fractional monetary unit) - a monetary unit
  # that is valued at a fraction (usually one hundredth)
  # of the basic monetary unit
  def subunits=(n)
    self.base_factor = 10 ** n
  end

  def subunits
    Math.log(base_factor, 10).round
  end

  def to_blockchain_api_settings(withdrawal_gas_speed=true)
    # We pass options are available as top-level hash keys and via options for
    # compatibility with Wallet#to_wallet_api_settings.
    opt = options.compact.deep_symbolize_keys

    # System have gas_speed configuration in blockchain level
    # And it differs for deposit collection transfer and withdrawal transfer
    # By default system use withdrawal_gas_speed
    gas_speed = withdrawal_gas_speed ? blockchain.withdrawal_gas_speed : blockchain.collection_gas_speed
    opt.merge!(gas_price: gas_speed) if gas_speed

    opt.deep_symbolize_keys.merge(id:                    currency.id,
                                  base_factor:           base_factor,
                                  min_collection_amount: min_collection_amount,
                                  options:               opt)
  end

  def update_fees
    market = Market.find_by(base_unit: currency.id, quote_unit: Peatio::App.config.platform_currency)
    ticker = Trade.market_ticker_from_influx(market.symbol) if market.present?
    price = ticker.present? ? ticker[:vwap].to_d : currency.price
    
    update_attributes(
      min_deposit_amount: round(blockchain.min_deposit_amount / price),
      min_collection_amount: round(blockchain.min_deposit_amount / price),
      withdraw_fee: round(blockchain.withdraw_fee / price)
    )
  end

  private

  def round(d)
    d.round(BlockchainCurrency::DB_DECIMAL_PRECISION, BigDecimal::ROUND_DOWN)
  end
end

# == Schema Information
# Schema version: 20210609094033
#
# Table name: blockchain_currencies
#
#  id                       :bigint           not null, primary key
#  currency_id              :string(255)      not null
#  blockchain_key           :string(255)
#  deposit_fee              :decimal(32, 16)  default(0.0), not null
#  min_deposit_amount       :decimal(32, 16)  default(0.0), not null
#  min_collection_amount    :decimal(32, 16)  default(0.0), not null
#  withdraw_fee             :decimal(32, 16)  default(0.0), not null
#  min_withdraw_amount      :decimal(32, 16)  default(0.0), not null
#  withdraw_limit_24h       :decimal(32, 16)  default(0.0), not null
#  withdraw_limit_72h       :decimal(32, 16)  default(0.0), not null
#  deposit_enabled          :boolean          default(TRUE), not null
#  withdrawal_enabled       :boolean          default(TRUE), not null
#  auto_update_fees_enabled :boolean          default(TRUE), not null
#  base_factor              :bigint           default(1), not null
#  status                   :string(32)       default("enabled"), not null
#  options                  :json
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
