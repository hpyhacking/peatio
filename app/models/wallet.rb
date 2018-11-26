# encoding: UTF-8
# frozen_string_literal: true


class Wallet < ActiveRecord::Base
  extend Enumerize

  # We use this attribute values rules for wallet kinds:
  # 1** - for deposit wallets.
  # 2** - for fee wallets.
  # 3** - for withdraw wallets (sorted by security hot < warm < cold).
  ENUMERIZED_KINDS = { deposit: 100, fee: 200, hot: 310, warm: 320, cold: 330 }.freeze
  enumerize :kind, in: ENUMERIZED_KINDS, scope: true

  GATEWAYS = %w[bitcoind bitcoincashd litecoind geth dashd rippled bitgo].freeze
  SETTING_ATTRIBUTES = %i[ uri
                           secret
                           bitgo_test_net
                           bitgo_wallet_id
                           bitgo_wallet_passphrase
                           bitgo_rest_api_root
                           bitgo_rest_api_access_token ].freeze

  include BelongsToCurrency

  store :settings, accessors: SETTING_ATTRIBUTES, coder: JSON

  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  validates :name,    presence: true, uniqueness: true
  validates :address, presence: true

  validates :status,  inclusion: { in: %w[active disabled] }
  validates :gateway, inclusion: { in: GATEWAYS }

  validates :nsig,        numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :max_balance, numericality: { greater_than_or_equal_to: 0 }
  validates :uri, url: { allow_blank: true }

  scope :active,   -> { where(status: :active) }
  scope :deposit,  -> { where(kind: kinds(deposit: true, values: true)) }
  scope :fee,      -> { where(kind: kinds(fee: true, values: true)) }
  scope :withdraw, -> { where(kind: kinds(withdraw: true, values: true)) }
  scope :ordered,  -> { order(kind: :asc) }

  before_validation do
    next unless blockchain_api&.supports_cash_addr_format? && address?
    self.address = CashAddr::Converter.to_cash_address(address)
  end

  class << self
    def kinds(options={})
      ENUMERIZED_KINDS
        .yield_self do |kinds|
          case
          when options.fetch(:deposit, false)
            kinds.select { |_k, v| v / 100 == 1 }
          when options.fetch(:fee, false)
            kinds.select { |_k, v| v / 100 == 2 }
          when options.fetch(:withdraw, false)
            kinds.select { |_k, v| v / 100 == 3 }
          else
            kinds
          end
        end
        .yield_self do |kinds|
          case
          when options.fetch(:keys, false)
            kinds.keys
          when options.fetch(:values, false)
            kinds.values
          else
            kinds
          end
        end
    end
  end

  def wallet_url
    blockchain.explorer_address.gsub('#{address}', address) if blockchain
  end
end

# == Schema Information
# Schema version: 20181017114624
#
# Table name: wallets
#
#  id             :integer          not null, primary key
#  blockchain_key :string(32)
#  currency_id    :string(10)
#  name           :string(64)
#  address        :string(255)      not null
#  kind           :integer          not null
#  nsig           :integer
#  gateway        :string(20)       default(""), not null
#  settings       :string(1000)     default({}), not null
#  max_balance    :decimal(32, 16)  default(0.0), not null
#  parent         :integer
#  status         :string(32)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_wallets_on_currency_id                      (currency_id)
#  index_wallets_on_kind                             (kind)
#  index_wallets_on_kind_and_currency_id_and_status  (kind,currency_id,status)
#  index_wallets_on_status                           (status)
#
