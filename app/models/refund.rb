# encoding: UTF-8
# frozen_string_literal: true

class Refund < ApplicationRecord
  extend Enumerize
  include AASM
  include AASM::Locking

  belongs_to :deposit, required: true

  aasm column: :state, whiny_transitions: false do
    state :pending, initial: true
    state :processed
    state :failed

    event :process do
      transitions from: :pending, to: :processed

      after do
        process_refund!
      end
    end

    event :fail do
      transitions from: %i[pending processed], to: :failed
    end
  end

  def process_refund!
    transaction = WalletService.new(Wallet.active_deposit_wallet(deposit.currency.id)).refund!(self)
    deposit.refund! if transaction.present?
  end
end

# == Schema Information
# Schema version: 20201125134745
#
# Table name: refunds
#
#  id         :bigint           not null, primary key
#  deposit_id :bigint           not null
#  state      :string(30)       not null
#  address    :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_refunds_on_deposit_id  (deposit_id)
#  index_refunds_on_state       (state)
#
