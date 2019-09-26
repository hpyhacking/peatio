# encoding: UTF-8
# frozen_string_literal: true

class Currency < ApplicationRecord

  # == Constants ============================================================

  DEFAULT_OPTIONS_SCHEMA = {
    erc20_contract_address: {
      title: 'ERC20 Contract Address',
      type: 'string'
    }
  }
  OPTIONS_ATTRIBUTES = %i[erc20_contract_address gas_limit gas_price].freeze

  # == Attributes ===========================================================

  attr_readonly :id,
                :type,
                :base_factor

  # Code is aliased to id because it's more user-friendly primary key.
  # It's preferred to use code where this attributes are equal.
  alias_attribute :code, :id

  # == Extensions ===========================================================

  store :options, accessors: OPTIONS_ATTRIBUTES, coder: JSON

  # == Relationships ========================================================

  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  # == Validations ==========================================================

  validates :code, presence: true, uniqueness: { case_sensitive: false }

  validates :blockchain_key,
            inclusion: { in: ->(_) { Blockchain.pluck(:key).map(&:to_s) } },
            if: :coin?

  validates :type, inclusion: { in: ->(_) { Currency.types.map(&:to_s) } }
  validates :symbol, presence: true, length: { maximum: 1 }
  validates :options, length: { maximum: 1000 }
  validates :base_factor, numericality: { greater_than_or_equal_to: 1, only_integer: true }

  validates :deposit_fee,
            :min_deposit_amount,
            :min_collection_amount,
            :withdraw_fee,
            :min_withdraw_amount,
            :withdraw_limit_24h,
            :withdraw_limit_72h,
            :precision,
            :position,
            numericality: { greater_than_or_equal_to: 0 }

  validate :validate_options

  # == Scopes ===============================================================

  scope :visible, -> { where(visible: true) }
  scope :deposit_enabled, -> { where(deposit_enabled: true) }
  scope :withdrawal_enabled, -> { where(withdrawal_enabled: true) }
  scope :ordered, -> { order(position: :asc) }
  scope :coins,   -> { where(type: :coin) }
  scope :fiats,   -> { where(type: :fiat) }

  # == Callbacks ============================================================

  before_validation :initialize_options
  before_validation { self.code = code.downcase }
  before_validation { self.deposit_fee = 0 unless fiat? }

  before_validation do
    self.erc20_contract_address = erc20_contract_address.try(:downcase) if erc20_contract_address.present?
  end

  after_create { Member.find_each(&:touch_accounts) }

  after_update :disable_markets

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

  delegate :explorer_transaction, :blockchain_api, :explorer_address, to: :blockchain

  types.each { |t| define_method("#{t}?") { type == t.to_s } }

  # Allows to dynamically check value of id/code:
  #
  #   id.btc? # true if code equals to "btc".
  #   code.eth? # true if code equals to "eth".
  def id
    super&.inquiry
  end

  # subunit (or fractional monetary unit) - a monetary unit
  # that is valued at a fraction (usually one hundredth)
  # of the basic monetary unit
  def subunits=(n)
    self.base_factor = 10 ** n
  end

  def as_json(*)
    { code: code,
      coin: coin?,
      fiat: fiat? }
  end

  def to_blockchain_api_settings
    # We pass options are available as top-level hash keys and via options for
    # compatibility with Wallet#to_wallet_api_settings.
    opt = options.compact.deep_symbolize_keys
    opt.deep_symbolize_keys.merge(id:          id,
                                  base_factor: base_factor,
                                  options:     opt)
  end

  def summary
    locked  = Account.with_currency(code).sum(:locked)
    balance = Account.with_currency(code).sum(:balance)
    { name:     id.upcase,
      sum:      locked + balance,
      balance:  balance,
      locked:   locked,
      coinable: coin?,
      hot:      coin? ? balance : nil }
  end

  def is_erc20?
    erc20_contract_address.present?
  end

  def dependent_markets
    Market.where('base_unit = ? OR quote_unit = ?', id, id)
  end

  def disable_markets
    unless visible?
      dependent_markets.update_all(state: :disabled)
    end
  end

  def initialize_options
    self.options = options.present? ? options : {}
  end

  def validate_options
    errors.add(:options, :invalid) unless Hash === options if options.present?
  end

  def build_options_schema
    default_schema = DEFAULT_OPTIONS_SCHEMA
    props_schema = (options.keys - OPTIONS_ATTRIBUTES.map(&:to_s)) \
                       .map{|v| [v, { title: v.to_s.humanize, format: "table"}]}.to_h
    default_schema.merge!(props_schema)
  end

  def set_options_values
    options.keys.present?  ? \
          options.keys.map{|v| [v, options[v]]}.to_h \
          : OPTIONS_ATTRIBUTES.map(&:to_s).map{|v| [v, '']}.to_h
  end

  def subunits
    Math.log(self.base_factor, 10).round
  end
end

# == Schema Information
# Schema version: 20190923085927
#
# Table name: currencies
#
#  id                    :string(10)       not null, primary key
#  name                  :string(255)
#  blockchain_key        :string(32)
#  symbol                :string(1)        not null
#  type                  :string(30)       default("coin"), not null
#  deposit_fee           :decimal(32, 16)  default(0.0), not null
#  min_deposit_amount    :decimal(32, 16)  default(0.0), not null
#  min_collection_amount :decimal(32, 16)  default(0.0), not null
#  withdraw_fee          :decimal(32, 16)  default(0.0), not null
#  min_withdraw_amount   :decimal(32, 16)  default(0.0), not null
#  withdraw_limit_24h    :decimal(32, 16)  default(0.0), not null
#  withdraw_limit_72h    :decimal(32, 16)  default(0.0), not null
#  position              :integer          default(0), not null
#  options               :string(1000)     default({})
#  visible               :boolean          default(TRUE), not null
#  deposit_enabled       :boolean          default(TRUE), not null
#  withdrawal_enabled    :boolean          default(TRUE), not null
#  base_factor           :bigint           default(1), not null
#  precision             :integer          default(8), not null
#  icon_url              :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_currencies_on_position  (position)
#  index_currencies_on_visible   (visible)
#
