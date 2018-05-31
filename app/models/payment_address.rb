# encoding: UTF-8
# frozen_string_literal: true

class PaymentAddress < ActiveRecord::Base
  include BelongsToCurrency
  include BelongsToAccount

  after_commit :enqueue_address_generation

  validates :address,    uniqueness: { scope: :currency_id }, if: :address?
  validates :account_id, uniqueness: true

  serialize :details, JSON

  before_validation do
    next unless currency&.supports_cash_addr_format? && address?
    self.address = CashAddr::Converter.to_legacy_address(address)
  end

  before_validation do
    next unless currency&.case_insensitive?
    self.address = address.try(:downcase)
  end

  def enqueue_address_generation
    if address.blank? && currency.coin?
      AMQPQueue.enqueue(:deposit_coin_address, { account_id: account.id }, { persistent: true })
    end
    self
  end
end

# == Schema Information
# Schema version: 20180529125011
#
# Table name: payment_addresses
#
#  id          :integer          not null, primary key
#  currency_id :string(10)       not null
#  account_id  :integer          not null
#  address     :string(64)
#  secret      :string(128)
#  details     :string(1024)     default({}), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_payment_addresses_on_account_id               (account_id) UNIQUE
#  index_payment_addresses_on_currency_id              (currency_id)
#  index_payment_addresses_on_currency_id_and_address  (currency_id,address) UNIQUE
#
