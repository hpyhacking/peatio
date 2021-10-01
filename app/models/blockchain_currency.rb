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
  belongs_to :parent, class_name: :BlockchainCurrency, foreign_key: %i[parent_id blockchain_key], primary_key: %i[currency_id blockchain_key]

  # == Validations ==========================================================

  validates :blockchain_key,
            inclusion: { in: ->(_) { Blockchain.pluck(:key).map(&:to_s) } }

  validates :parent_id, allow_blank: true,
            inclusion: { in: ->(_) { Currency.coins_without_tokens.pluck(:id).map(&:to_s) } },
            if: -> { currency.coin? }

  validates :options, length: { maximum: 1000 }
  validates :base_factor, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  validates :blockchain_key, uniqueness: { scope: :currency_id }

  validates :deposit_fee,
            :min_deposit_amount,
            :min_collection_amount,
            :withdraw_fee,
            :min_withdraw_amount,
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

  before_validation do
    self.erc20_contract_address = erc20_contract_address.try(:downcase) if erc20_contract_address.present?
    self.parent_id = nil if currency.fiat?
  end

  after_create do
    link_wallets
    update_fees if auto_update_fees_enabled && currency.coin?
  end

  after_create :link_as_default_network, if: -> { currency.default_network.blank? }

  # == Class Methods ========================================================

  class << self
    def find_network(blockchain_key, currency_id)
      blockchain_currency = BlockchainCurrency.find_by(currency_id: currency_id, blockchain_key: blockchain_key)

      currency = Currency.find_by(id: currency_id)
      blockchain_currency = currency.default_network if currency.present? && blockchain_currency.blank?

      blockchain_currency
    end
  end

  # == Instance Methods =====================================================
  delegate :explorer_transaction, :explorer_address, :blockchain_api, :description, :warning, :protocol, to: :blockchain

  def initialize_defaults
    self.options = {} if options.blank?
  end

  def blockchain
    Rails.cache.fetch("#{currency_id}_#{blockchain_key}_blockchain", expires_in: 60) { Blockchain.find_by(key: blockchain_key) }
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

  def link_wallets
    if parent_id.present?
      # Iterate through active deposit/withdraw wallets
      Wallet.active.where(blockchain_key: blockchain_key)
                   .where.not(kind: :fee).with_currency(parent_id).each do |wallet|
        # Link parent currency with wallet
        CurrencyWallet.create(currency_id: currency_id, wallet_id: wallet.id)
      end
    end
  end

  def update_fees
    update_attributes(
      min_deposit_amount: round(blockchain.min_deposit_amount / currency.price),
      min_collection_amount: round(blockchain.min_deposit_amount / currency.price),
      withdraw_fee: round(blockchain.withdraw_fee / currency.price),
      min_withdraw_amount: round(blockchain.min_withdraw_amount / currency.price)
    )
  end

  def link_as_default_network
    currency.update_column(:default_network_id, id)
  end

  private

  def round(d)
    d.round(BlockchainCurrency::DB_DECIMAL_PRECISION, BigDecimal::ROUND_DOWN)
  end
end

# == Schema Information
# Schema version: 20211001083227
#
# Table name: blockchain_currencies
#
#  id                       :bigint           not null, primary key
#  currency_id              :string(255)      not null
#  blockchain_key           :string(255)      not null
#  parent_id                :string(255)
#  deposit_fee              :decimal(32, 16)  default(0.0), not null
#  min_deposit_amount       :decimal(32, 16)  default(0.0), not null
#  min_collection_amount    :decimal(32, 16)  default(0.0), not null
#  withdraw_fee             :decimal(32, 16)  default(0.0), not null
#  min_withdraw_amount      :decimal(32, 16)  default(0.0), not null
#  deposit_enabled          :boolean          default(TRUE), not null
#  withdrawal_enabled       :boolean          default(TRUE), not null
#  auto_update_fees_enabled :boolean          default(TRUE), not null
#  base_factor              :bigint           default(1), not null
#  status                   :string(32)       default("enabled"), not null
#  options                  :json
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_blockchain_currencies_on_parent_id  (parent_id)
#
