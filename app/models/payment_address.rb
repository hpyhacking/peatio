# encoding: UTF-8
# frozen_string_literal: true

class PaymentAddress < ActiveRecord::Base
  include BelongsToCurrency
  include BelongsToAccount

  after_commit :enqueue_address_generation

  validates :address, uniqueness: { scope: :currency_id }, if: :address?

  serialize :details, JSON

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
      AMQPQueue.enqueue(:deposit_coin_address, { account_id: account.id }, { persistent: true })
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
end

# == Schema Information
# Schema version: 20180925123806
#
# Table name: payment_addresses
#
#  id          :integer          not null, primary key
#  currency_id :string(10)       not null
#  account_id  :integer          not null
#  address     :string(95)
#  secret      :string(128)
#  details     :string(1024)     default({}), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_payment_addresses_on_currency_id_and_address  (currency_id,address) UNIQUE
#
