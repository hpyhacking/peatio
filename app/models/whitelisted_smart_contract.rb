# encoding: UTF-8
# frozen_string_literal: true

class WhitelistedSmartContract < ApplicationRecord
  # == Constants ============================================================

  STATES = %w[active disabled].freeze

  # == Relationships ========================================================

  belongs_to :blockchain, foreign_key: :blockchain_key, primary_key: :key

  # == Validations ==========================================================

  validates :address, presence: true, uniqueness: { scope: :blockchain_key }

  validates :blockchain_key,
            presence: true,
            inclusion: { in: ->(_) { Blockchain.pluck(:key).map(&:to_s) } }

  validates :state, inclusion: { in: STATES }

  # == Scopes ===============================================================

  scope :active, -> { where(state: :active) }
  scope :ordered, -> { order(kind: :asc) }

  after_save :update_blockchain

  def update_blockchain
    blockchain.touch
  end
end

# == Schema Information
# Schema version: 20210128144535
#
# Table name: whitelisted_smart_contracts
#
#  id             :bigint           not null, primary key
#  description    :string(255)
#  address        :string(255)      not null
#  state          :string(30)       not null
#  blockchain_key :string(32)       not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_whitelisted_smart_contracts_on_address_and_blockchain_key  (address,blockchain_key) UNIQUE
#
