# frozen_string_literal: true

class Account < ApplicationRecord
  AccountError = Class.new(StandardError)

  belongs_to :currency, required: true
  belongs_to :member, required: true

  acts_as_eventable prefix: 'account', on: %i[create update]

  ZERO = 0.to_d

  validates :member_id, uniqueness: { scope: :currency_id }
  validates :balance, :locked, numericality: { greater_than_or_equal_to: 0.to_d }

  scope :visible, -> { joins(:currency).merge(Currency.where(visible: true)) }
  scope :ordered, -> { joins(:currency).order(position: :asc) }

  def as_json_for_event_api
    {
      id: id,
      member_id: member_id,
      currency_id: currency_id,
      balance: balance,
      locked: locked,
      created_at: created_at&.iso8601,
      updated_at: updated_at&.iso8601
    }
  end

  def plus_funds!(amount)
    update_columns(attributes_after_plus_funds!(amount))
  end

  def plus_funds(amount)
    with_lock { plus_funds!(amount) }
    self
  end

  def attributes_after_plus_funds!(amount)
    if amount <= ZERO
      raise AccountError, "Cannot add funds (account id: #{id}, amount: #{amount}, balance: #{balance})."
    end

    { balance: balance + amount }
  end

  def plus_locked_funds!(amount)
    update_columns(attributes_after_plus_locked_funds!(amount))
  end

  def plus_locked_funds(amount)
    with_lock { plus_locked_funds!(amount) }
    self
  end

  def attributes_after_plus_locked_funds!(amount)
    if amount <= ZERO
      raise AccountError, "Cannot add funds (account id: #{id}, amount: #{amount}, locked: #{locked})."
    end

    { locked: locked + amount }
  end

  def sub_funds!(amount)
    update_columns(attributes_after_sub_funds!(amount))
  end

  def sub_funds(amount)
    with_lock { sub_funds!(amount) }
    self
  end

  def attributes_after_sub_funds!(amount)
    if amount <= ZERO || amount > balance
      raise AccountError, "Cannot subtract funds (account id: #{id}, amount: #{amount}, balance: #{balance})."
    end

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
    if amount <= ZERO || amount > balance
      raise AccountError, "Cannot lock funds (account id: #{id}, amount: #{amount}, balance: #{balance}, locked: #{locked})."
    end

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
    if amount <= ZERO || amount > locked
      raise AccountError, "Cannot unlock funds (account id: #{id}, amount: #{amount}, balance: #{balance} locked: #{locked})."
    end

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
    if amount <= ZERO || amount > locked
      raise AccountError, "Cannot unlock and sub funds (account id: #{id}, amount: #{amount}, locked: #{locked})."
    end

    { locked: locked - amount }
  end

  def amount
    balance + locked
  end
end

# == Schema Information
# Schema version: 20201125134745
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
