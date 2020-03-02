# encoding: UTF-8
# frozen_string_literal: true

class PaymentAddress < ApplicationRecord
  include Vault::EncryptedModel
  include BelongsToCurrency
  include BelongsToAccount

  vault_lazy_decrypt!

  after_commit :enqueue_address_generation

  validates :address, uniqueness: { scope: :currency_id }, if: :address?

  vault_attribute :details, serialize: :json, default: {}
  vault_attribute :secret

  before_validation do
    next if blockchain_api&.case_sensitive?
    self.address = address.try(:downcase)
  end

  before_validation do
    next unless blockchain_api&.supports_cash_addr_format? && address?
    self.address = CashAddr::Converter.to_cash_address(address)
  end

  def enqueue_address_generation
    if address.blank? && currency.coin?
      AMQP::Queue.enqueue(:deposit_coin_address, { account_id: account.id }, { persistent: true })
    end
    self
  end

  def format_address(format)
    format == 'legacy' ? to_legacy_address : to_cash_address
  end

  def to_legacy_address
    CashAddr::Converter.to_legacy_address(address)
  end

  def to_cash_address
    CashAddr::Converter.to_cash_address(address)
  end

  def trigger_address_event
    ::AMQP::Queue.enqueue_event('private', account.member.uid, :deposit_address, type: :create,
                          currency: currency.code,
                          address:  address)
  end
end

# == Schema Information
# Schema version: 20190807092706
#
# Table name: payment_addresses
#
#  id                :integer          not null, primary key
#  currency_id       :string(10)       not null
#  account_id        :integer          not null
#  address           :string(95)
#  secret_encrypted  :string(255)
#  details_encrypted :string(1024)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_payment_addresses_on_currency_id_and_address  (currency_id,address) UNIQUE
#
