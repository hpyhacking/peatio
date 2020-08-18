# frozen_string_literal: true

class Engine < ApplicationRecord
  # == Constants ============================================================

  include Vault::EncryptedModel

  vault_lazy_decrypt!

  extend Enumerize
  STATES = { online: 1, offline: 0 }.freeze
  enumerize :state, in: STATES, scope: true

  # == Attributes ===========================================================

  vault_attribute :key
  vault_attribute :secret
  vault_attribute :data, serialize: :json, default: {}

  # == Extensions ===========================================================

  # == Relationships ========================================================

  has_many :markets
  has_one :member, foreign_key: :uid, primary_key: :uid

  # == Validations ==========================================================

  validates :name, uniqueness: true, presence: true
  validates :driver, presence: true

  # == Scopes ===============================================================

  # == Callbacks ============================================================

  before_create { self.name = name.strip.downcase }

  # == Class Methods ========================================================

  # == Instance Methods =====================================================
end

# == Schema Information
# Schema version: 20200504183201
#
# Table name: engines
#
#  id               :bigint           not null, primary key
#  name             :string(255)      not null
#  driver           :string(255)      not null
#  uid              :string(255)
#  url              :string(255)
#  key_encrypted    :string(255)
#  secret_encrypted :string(255)
#  data_encrypted   :string(1024)
#  state            :integer          default("1"), not null
#
