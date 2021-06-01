# encoding: UTF-8
# frozen_string_literal: true

module FeeChargeable
  extend ActiveSupport::Concern

  included do
    attr_readonly :amount, :fee

    validates :amount, presence: true, numericality: { greater_than: 0.to_d }
    validates :fee,    presence: true, numericality: { greater_than_or_equal_to: 0.to_d }
    if self <= Deposit

      before_validation on: :create do
        next unless currency
        next unless blockchain_currency

        self.fee  ||= blockchain_currency.deposit_fee
        self.amount = amount.to_d - fee
      end

      validates :fee, numericality: { less_than: :amount }, if: -> (record) { record.amount.to_d > 0.to_d }
    end

    if self <= Withdraw
      attr_readonly :sum

      before_validation on: :create do
        next unless currency
        next unless blockchain_currency

        self.sum  ||= 0.to_d
        self.fee  ||= blockchain_currency.withdraw_fee
        self.amount = sum - fee
      end

      validates :sum,
                presence: true,
                numericality: { greater_than: 0.to_d },
                precision: { less_than_or_eq_to: ->(w) { w.currency.coin? ? w.blockchain_currency.subunits : w.currency.precision } }

      validates :amount,
                precision: { less_than_or_eq_to: ->(w) { w.currency.coin? ? w.blockchain_currency.subunits : w.currency.precision } }

      validate on: :create do
        next if !account || [sum, amount, fee].any?(&:blank?)
        if sum > account.balance || (amount + fee) > sum
          raise ::Account::AccountError, 'Account balance is insufficient'
        end
      end
    end
  end
end
