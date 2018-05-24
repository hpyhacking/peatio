# encoding: UTF-8
# frozen_string_literal: true

class Account < ActiveRecord::Base
  class AccountError < StandardError

  end

  include BelongsToCurrency
  include BelongsToMember

  ZERO = 0.to_d

  has_many :payment_addresses, -> { order(id: :asc) }
  has_many :partial_trees, -> { order(id: :desc) }

  validates :member_id, uniqueness: { scope: :currency_id }
  validates :balance, :locked, numericality: { greater_than_or_equal_to: 0.to_d }

  scope :enabled, -> { joins(:currency).merge(Currency.where(enabled: true)) }

  after_commit :trigger, :sync_update

  def payment_address
    return unless currency.coin?
    payment_addresses.last&.enqueue_address_generation || payment_addresses.create!(currency: currency)
  end

  def plus_funds(amount)
    with_lock do
      raise AccountError, "Cannot add funds (amount: #{amount})." if amount <= ZERO
      update_columns(balance: balance + amount)
    end
    self
  end

  def sub_funds(amount)
    with_lock do
      raise AccountError, "Cannot subtract funds (amount: #{amount})." if amount <= ZERO || amount > balance
      update_columns(balance: balance - amount)
    end
    self
  end

  def lock_funds(amount)
    with_lock do
      raise AccountError, "Cannot lock funds (amount: #{amount})." if amount <= ZERO || amount > balance
      update_columns(balance: balance - amount, locked: locked + amount)
    end
    self
  end

  def unlock_funds(amount)
    with_lock do
      raise AccountError, "Cannot unlock funds (amount: #{amount})." if amount <= ZERO || amount > locked
      update_columns(balance: balance + amount, locked: locked - amount)
    end
    self
  end

  def unlock_and_sub_funds(amount)
    with_lock do
      raise AccountError, "Cannot unlock funds (amount: #{amount})." if amount <= ZERO || amount > locked
      update_columns(locked: locked - amount)
    end
    self
  end

  def amount
    balance + locked
  end

  def trigger
    AMQPQueue.enqueue(:pusher_member, member_id: member.id, event: 'account', data: {
      balance:  balance.to_s('F'),
      locked:   locked.to_s('F'),
      currency: currency
    })
  end

  def as_json(*)
    super.merge! \
      deposit_address: payment_address&.address,
      currency:        currency.code
  end

  private

  def sync_update
    return unless member
    Pusher["private-#{member.sn}"].trigger_async 'accounts', {
      id:         id,
      type:       'update',
      attributes: { balance: balance, locked: locked }
    }
  end

end

# == Schema Information
# Schema version: 20180524170927
#
# Table name: accounts
#
#  id          :integer          not null, primary key
#  member_id   :integer          not null
#  currency_id :integer          not null
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
