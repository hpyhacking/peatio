# encoding: UTF-8
# frozen_string_literal: true

class Blockchain < ActiveRecord::Base
  has_many :currencies, foreign_key: :blockchain_key, primary_key: :key
  has_many :wallets, foreign_key: :blockchain_key, primary_key: :key

  validates :key, :name, :client, presence: true
  validates :status, inclusion: { in: %w[active disabled] }
  validates :height, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :min_confirmations, numericality: { greater_than_or_equal_to: 1, only_integer: true }
  validates :server, url: { allow_blank: true }

  def explorer=(hash)
    write_attribute(:explorer_address, hash.fetch('address'))
    write_attribute(:explorer_transaction, hash.fetch('transaction'))
  end

  def status
    super&.inquiry
  end

  def blockchain_api
    BlockchainClient[key]
  end
end

# == Schema Information
# Schema version: 20180708171446
#
# Table name: blockchains
#
#  id                   :integer          not null, primary key
#  key                  :string(255)      not null
#  name                 :string(255)
#  client               :string(255)      not null
#  server               :string(255)
#  height               :integer          not null
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
