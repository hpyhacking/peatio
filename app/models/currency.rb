# encoding: UTF-8
# frozen_string_literal: true

class Currency < ApplicationRecord

  DEFAULT_OPTIONS_SCHEMA = {
    erc20_contract_address: {
      title: 'ERC20 Contract Address',
      type: 'string'
    }
  }
  OPTIONS_ATTRIBUTES = %i[erc20_contract_address gas_limit gas_price].freeze
  store :options, accessors: OPTIONS_ATTRIBUTES, coder: JSON

  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  # NOTE: type column reserved for STI
  self.inheritance_column = nil

  validates :id, presence: true, uniqueness: true
  # TODO: Add specs to this validation.
  validates :blockchain_key,
            inclusion: { in: -> (_) { Blockchain.pluck(:key).map(&:to_s) } },
            if: :coin?

  validates :type, inclusion: { in: -> (_) { Currency.types.map(&:to_s) } }
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
            numericality: { greater_than_or_equal_to: 0 }

  validate :validate_options
  validate { errors.add(:base, 'Cannot disable display currency!') if disabled? && code == ENV.fetch('DISPLAY_CURRENCY').downcase }

  # TODO: Add specs to this validation.
  validate :must_not_disable_all_markets, on: :update

  before_validation :initialize_options
  before_validation { self.deposit_fee = 0 unless fiat? }

  before_validation do
    self.erc20_contract_address = erc20_contract_address.try(:downcase) if erc20_contract_address.present?
  end

  after_create { Member.find_each(&:touch_accounts) }

  after_update :disable_markets

  scope :enabled, -> { where(enabled: true) }
  scope :ordered, -> { order(position: :asc) }
  scope :coins,   -> { where(type: :coin) }
  scope :fiats,   -> { where(type: :fiat) }

  delegate :explorer_transaction, :blockchain_api, :explorer_address, to: :blockchain

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

  # Allows to dynamically check value of code:
  #
  #   code.btc? # true if code equals to "btc".
  #   code.xrp? # true if code equals to "xrp".
  #
  def code
    id&.inquiry
  end

  def code=(code)
    self.id = code.to_s.downcase
  end

  types.each { |t| define_method("#{t}?") { type == t.to_s } }

  def as_json(*)
    { code: code,
      coin: coin?,
      fiat: fiat? }
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

  def disabled?
    !enabled
  end

  def is_erc20?
    erc20_contract_address.present?
  end

  def dependent_markets
    Market.where('ask_unit = ? OR bid_unit = ?', id, id)
  end

  def disable_markets
    unless enabled?
      dependent_markets.update_all(enabled: false)
    end
  end

  def must_not_disable_all_markets
    if enabled_was && !enabled? && (Market.enabled.count - dependent_markets.enabled.count).zero?
      errors.add(:currency, 'disables all enabled markets.')
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

  attr_readonly :id,
                :code,
                :type
end

# == Schema Information
# Schema version: 20190225171726
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
#  enabled               :boolean          default(TRUE), not null
#  base_factor           :bigint(8)        default(1), not null
#  precision             :integer          default(8), not null
#  icon_url              :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_currencies_on_enabled           (enabled)
#  index_currencies_on_enabled_and_code  (enabled)
#  index_currencies_on_position          (position)
#
