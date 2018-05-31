# encoding: UTF-8
# frozen_string_literal: true

class Currency < ActiveRecord::Base
  serialize :options, JSON

  # NOTE: type column reserved for STI
  self.inheritance_column = nil

  validates :id, presence: true, uniqueness: true
  validates :type, inclusion: { in: -> (_) { Currency.types.map(&:to_s) } }
  validates :symbol, presence: true, length: { maximum: 1 }
  validates :json_rpc_endpoint, :rest_api_endpoint, length: { maximum: 200 }, url: { allow_blank: true }
  validates :options, length: { maximum: 1000 }
  validates :wallet_url_template, :transaction_url_template, length: { maximum: 200 }, url: { allow_blank: true }
  validates :quick_withdraw_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :base_factor, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :deposit_confirmations, numericality: { greater_than_or_equal_to: 0, only_integer: true }, if: :coin?
  validates :withdraw_fee, :deposit_fee, numericality: { greater_than_or_equal_to: 0 }
  validate { errors.add(:options, :invalid) unless Hash === options }

  before_validation { self.deposit_fee = 0 unless fiat? }

  before_validation do
    next unless supports_cash_addr_format? && bitgo_wallet_address?
    self.bitgo_wallet_address = CashAddr::Converter.to_legacy_address(bitgo_wallet_address)
  end

  before_validation do
    next if case_sensitive?
    self.bitgo_wallet_address   = bitgo_wallet_address.try(:downcase)
    self.erc20_contract_address = erc20_contract_address.try(:downcase)
  end

  after_create { Member.find_each(&:touch_accounts) }

  scope :enabled, -> { where(enabled: true) }
  scope :ordered, -> { order(id: :asc) }
  scope :coins,   -> { where(type: :coin) }
  scope :fiats,   -> { where(type: :fiat) }

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

    def coin_codes(options = {})
      coins.codes(options)
    end

    def fiat_codes(options = {})
      fiats.codes(options)
    end

    def types
      %i[fiat coin].freeze
    end
  end

  def api
    CoinAPI[code]
  end

  def balance_cache_key
    "peatio:hotwallet:#{code}:balance"
  end

  def balance
    Rails.cache.read(balance_cache_key) || 0
  end

  def refresh_balance
    Rails.cache.write(balance_cache_key, api.load_balance || 'N/A') if coin?
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
    { code:                     code,
      coin:                     coin?,
      fiat:                     fiat?,
      transaction_url_template: transaction_url_template }
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

  class << self
    def nested_attr(*names)
      names.each do |name|
        name_string = name.to_s
        define_method(name)              { options[name_string] }
        define_method(name_string + '?') { options[name_string].present? }
        define_method(name_string + '=') { |value| options[name_string] = value }
        define_method(name_string + '!') { options.fetch!(name_string) }
      end
    end
  end

  nested_attr \
    :api_client,
    :json_rpc_endpoint,
    :rest_api_endpoint,
    :deposit_confirmations,
    :bitgo_test_net,
    :bitgo_wallet_id,
    :bitgo_wallet_address,
    :bitgo_wallet_passphrase,
    :bitgo_rest_api_root,
    :bitgo_rest_api_access_token,
    :wallet_url_template,
    :transaction_url_template,
    :erc20_contract_address,
    :case_sensitive,
    :supports_cash_addr_format

  def deposit_confirmations
    options['deposit_confirmations'].to_i
  end

  def deposit_confirmations=(n)
    options['deposit_confirmations'] = n.to_i
  end

  def case_insensitive?
    !case_sensitive?
  end

  attr_readonly :id,
                :code,
                :type,
                :case_sensitive,
                :erc20_contract_address,
                :api_client,
                :bitgo_test_net,
                :bitgo_wallet_id,
                :bitgo_wallet_address,
                :bitgo_wallet_passphrase,
                :bitgo_rest_api_root,
                :bitgo_rest_api_access_token,
                :supports_cash_addr_format
end

# == Schema Information
# Schema version: 20180529125011
#
# Table name: currencies
#
#  id                   :string(10)       not null, primary key
#  symbol               :string(1)        not null
#  type                 :string(30)       default("coin"), not null
#  deposit_fee          :decimal(32, 16)  default(0.0), not null
#  quick_withdraw_limit :decimal(32, 16)  default(0.0), not null
#  withdraw_fee         :decimal(32, 16)  default(0.0), not null
#  options              :string(1000)     default({}), not null
#  enabled              :boolean          default(TRUE), not null
#  base_factor          :integer          default(1), not null
#  precision            :integer          default(8), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_currencies_on_enabled  (enabled)
#
