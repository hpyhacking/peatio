# encoding: UTF-8
# frozen_string_literal: true

module BelongsToCurrency
  extend ActiveSupport::Concern

  included do
    belongs_to :currency, required: true

    validate do
      account  = try(:account)
      currency = self.currency
      if account && currency && account.currency != currency
        errors.add(:currency, :invalid)
        errors.add(:account, :invalid)
      end
    end

    delegate :coin?, :fiat?, :blockchain_api, to: :currency

    scope :with_currency, -> (model_or_id) do
      id = case model_or_id
        when Currency then model_or_id.code
        else model_or_id
      end
      where(currency_id: id)
    end
  end

  def amount_to_base_unit!
    x = amount.to_d * currency.base_factor
    unless (x % 1).zero?
      raise StandardError::Error, "Failed to convert value to base (smallest) unit because it exceeds the maximum precision: " +
          "#{amount.to_d} - #{x.to_d} must be equal to zero."
    end
    x.to_i
  end
end
