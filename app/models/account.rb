# encoding: UTF-8
# frozen_string_literal: true

class Account < ActiveRecord::Base
  class AccountError < StandardError

  end

  include BelongsToCurrency
  include BelongsToMember

  ZERO = 0.to_d

  has_many :payment_addresses, -> { order(id: :asc) }

  validates :member_id, uniqueness: { scope: :currency_id }
  validates :balance, :locked, numericality: { greater_than_or_equal_to: 0.to_d }

  scope :enabled, -> { joins(:currency).merge(Currency.where(enabled: true)) }

  # Returns active deposit address for account or creates new if any exists.
  def payment_address
    return unless currency.coin?
    payment_addresses.last&.enqueue_address_generation || payment_addresses.create!(currency: currency)
  end

  # Attempts to create additional deposit address for account.
  def payment_address!
    return unless currency.coin?
    record = payment_address

    # The address generation process is in progress.
    if record.address.blank?
      record
    else
      # allows user to have multiple addresses.
      payment_addresses.create!(currency: currency)
    end
  end

  def plus_funds!(amount)
    update_columns((attributes_after_plus_funds!(amount)))
  end

  def plus_funds(amount)
    with_lock { plus_funds!(amount) }
    self
  end

  def attributes_after_plus_funds!(amount)
    raise AccountError, "Cannot add funds (amount: #{amount})." if amount <= ZERO
    { balance: balance + amount }
  end

  def sub_funds!(amount)
    update_columns(attributes_after_sub_funds!(amount))
  end

  def sub_funds(amount)
    with_lock { sub_funds!(amount) }
    self
  end

  def attributes_after_sub_funds!(amount)
    raise AccountError, "Cannot subtract funds (amount: #{amount})." if amount <= ZERO || amount > balance
    { balance: balance - amount }
  end

  def lock_funds!(amount)
    update_columns(attributes_after_lock_funds!(amount))
  end

  def lock_funds(amount)
    with_lock { lock_funds!(amount) }
    self
  end

  def attributes_after_lock_funds!(amount)
    raise AccountError, "Cannot lock funds (amount: #{amount})." if amount <= ZERO || amount > balance
    { balance: balance - amount, locked: locked + amount }
  end

  def unlock_funds!(amount)
    update_columns(attributes_after_unlock_funds!(amount))
  end

  def unlock_funds(amount)
    with_lock { unlock_funds!(amount) }
    self
  end

  def attributes_after_unlock_funds!(amount)
    raise AccountError, "Cannot unlock funds (amount: #{amount})." if amount <= ZERO || amount > locked
    { balance: balance + amount, locked: locked - amount }
  end

  def unlock_and_sub_funds!(amount)
    update_columns(attributes_after_unlock_and_sub_funds!(amount))
  end

  def unlock_and_sub_funds(amount)
    with_lock { unlock_and_sub_funds!(amount) }
    self
  end

  def attributes_after_unlock_and_sub_funds!(amount)
    raise AccountError, "Cannot unlock funds (amount: #{amount})." if amount <= ZERO || amount > locked
    { locked: locked - amount }
  end

  def amount
    balance + locked
  end

  def as_json(*)
    super.merge! \
      deposit_address: payment_address&.address,
      currency:        currency_id
  end
end

# == Schema Information
# Schema version: 20180529125011
#
# Table name: accounts
#
#  id          :integer          not null, primary key
#  member_id   :integer          not null
#  currency_id :string(10)       not null
#  balance     :decimal(32, 16)  default(0.0), not null
#  locked      :decimal(32, 16)  default(0.0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_accounts_on_currency_id_and_member_id  (currency_id,member_id) UNIQUE
#  index_accounts_on_member_id                  (member_id)
#
