# encoding: UTF-8
# frozen_string_literal: true

class Wallet < ActiveRecord::Base
  KIND = %w[hot warm cold deposit].freeze
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
  validates :kind,    inclusion: { in: KIND }
  validates :gateway, inclusion: { in: GATEWAYS }

  validates :nsig,        numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :max_balance, numericality: { greater_than_or_equal_to: 0 }
  validates :uri, url: { allow_blank: true }

  scope :active,   -> { where(status: :active) }
  scope :deposit,  -> { where(kind: :deposit) }
  scope :withdraw, -> { where.not(kind: :deposit) }

  before_validation do
    next unless blockchain_api&.supports_cash_addr_format? && address?
    self.address = CashAddr::Converter.to_cash_address(address)
  end

  def wallet_url
    blockchain.explorer_address.gsub('#{address}', address) if blockchain
  end
end

# == Schema Information
# Schema version: 20180813105100
#
# Table name: wallets
#
#  id             :integer          not null, primary key
#  blockchain_key :string(32)
#  currency_id    :string(10)
#  name           :string(64)
#  address        :string(255)      not null
#  kind           :string(32)       not null
#  nsig           :integer
#  gateway        :string(20)       default(""), not null
#  settings       :string(1000)     default({}), not null
#  max_balance    :decimal(32, 16)  default(0.0), not null
#  parent         :integer
#  status         :string(32)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
