# encoding: UTF-8
# frozen_string_literal: true

class Blockchain < ApplicationRecord
  include Vault::EncryptedModel

  vault_lazy_decrypt!

  vault_attribute :server

  has_many :currencies, foreign_key: :blockchain_key, primary_key: :key
  has_many :wallets, foreign_key: :blockchain_key, primary_key: :key
  has_many :whitelisted_smart_contracts, foreign_key: :blockchain_key, primary_key: :key

  validates :key, :name, :client, presence: true
  validates :key, uniqueness: true
  validates :status, inclusion: { in: %w[active disabled] }
  validates :height,
            :min_confirmations,
            numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :server, url: { allow_blank: true }
  validates :client, inclusion: { in: -> (_) { clients.map(&:to_s) } }

  before_create { self.key = self.key.strip.downcase }

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

  def blockchain_api
    BlockchainService.new(self)
  end

  # The latest block which blockchain worker has processed
  def processed_height
    height + min_confirmations
  end
end

# == Schema Information
# Schema version: 20201125134745
#
# Table name: blockchains
#
#  id                   :integer          not null, primary key
#  key                  :string(255)      not null
#  name                 :string(255)
#  client               :string(255)      not null
#  server_encrypted     :string(1024)
#  height               :bigint           not null
#  explorer_address     :string(255)
#  explorer_transaction :string(255)
#  min_confirmations    :integer          default(6), not null
#  status               :string(255)      not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_blockchains_on_key     (key) UNIQUE
#  index_blockchains_on_status  (status)
#
