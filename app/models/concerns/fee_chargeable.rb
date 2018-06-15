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
        self.fee  ||= currency.deposit_fee
        self.amount = amount.to_d - fee
      end

      validates :fee, numericality: { less_than: :amount }, if: -> (record) { record.amount.to_d > 0.to_d }
    end

    if self <= Withdraw
      attr_readonly :sum

      before_validation on: :create do
        next unless currency
        
        if sum.present?
          self.sum = sum.round(currency.precision, BigDecimal::ROUND_DOWN)
        end

        self.sum  ||= 0.to_d
        self.fee  ||= currency.withdraw_fee
        self.amount = sum - fee
      end

      validates :sum, presence: true, numericality: { greater_than: 0.to_d }

      validate on: :create do
        next if !account || [sum, amount, fee].any?(&:blank?)
        if sum > account.balance || (amount + fee) > sum
          errors.add :base, -> { I18n.t('activerecord.errors.models.withdraw.account_balance_is_poor') }
        end
      end
    end
  end
end
