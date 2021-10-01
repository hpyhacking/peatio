# encoding: UTF-8
# frozen_string_literal: true

class Blockchain < ApplicationRecord
  GAS_SPEEDS = %w[standard safelow fast].freeze
  STATES = %w[active idle disabled].freeze

  include Vault::EncryptedModel

  vault_lazy_decrypt!

  vault_attribute :server

  has_many :wallets, foreign_key: :blockchain_key, primary_key: :key
  has_many :whitelisted_smart_contracts, foreign_key: :blockchain_key, primary_key: :key
  has_many :blockchain_currencies, foreign_key: :blockchain_key, primary_key: :key

  validates :key, :name, :client, :protocol, :min_deposit_amount, :min_withdraw_amount, :withdraw_fee, presence: true
  validates :key, :protocol, uniqueness: true
  validates :status, inclusion: { in: Blockchain::STATES }
  validates :height,
            :min_confirmations,
            numericality: { greater_than_or_equal_to: 1, only_integer: true },
            if: -> { client != Peatio::Blockchain.registry.adapters.key(Fiat).to_s }

  validates :server, url: { allow_blank: true }
  validates :client, inclusion: { in: -> (_) { clients.map(&:to_s) } }
  validates :collection_gas_speed, :withdrawal_gas_speed, inclusion: { in: GAS_SPEEDS }, allow_blank: true

  validates :min_deposit_amount,
            :withdraw_fee,
            :min_withdraw_amount,
            numericality: { greater_than_or_equal_to: 0 }

  before_create { self.key = self.key.strip.downcase }
  before_validation :initialize_fiat_defaults, on: :create
  after_save :update_networks_state

  scope :active,   -> { where(status: :active) }

  class << self
    def clients
      Peatio::Blockchain.registry.adapters.keys
    end
  end

  def explorer=(hash)
    write_attribute(:explorer_address, hash.fetch('address'))
    write_attribute(:explorer_transaction, hash.fetch('transaction'))
  end

  def status
    super&.inquiry
  end

  def update_networks_state
    blockchain_currencies.update_all(status: :disabled) if status == 'disabled'
  end

  def initialize_fiat_defaults
    if client == Peatio::Blockchain.registry.adapters.key(Fiat).to_s
      self.status = 'idle'
      self.height = 0
    end
  end

  def blockchain_api
    BlockchainService.new(self)
  end

  # The latest block which blockchain worker has processed
  def processed_height
    height + min_confirmations
  end
end

# == Schema Information
# Schema version: 20210611085637
#
# Table name: blockchains
#
#  id                   :bigint           not null, primary key
#  key                  :string(255)      not null
#  name                 :string(255)
#  client               :string(255)      not null
#  server_encrypted     :string(1024)
#  height               :bigint           not null
#  collection_gas_speed :string(255)
#  withdrawal_gas_speed :string(255)
#  description          :text(65535)
#  warning              :text(65535)
#  protocol             :string(255)      not null
#  explorer_address     :string(255)
#  explorer_transaction :string(255)
#  min_confirmations    :integer          default(6), not null
#  min_deposit_amount   :decimal(32, 16)  default(0.0), not null
#  withdraw_fee         :decimal(32, 16)  default(0.0), not null
#  min_withdraw_amount  :decimal(32, 16)  default(0.0), not null
#  status               :string(255)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_blockchains_on_key     (key) UNIQUE
#  index_blockchains_on_status  (status)
#
