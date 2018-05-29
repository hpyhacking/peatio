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

    delegate :coin?, :fiat?, to: :currency

    scope :with_currency, -> (model_or_id_or_code) do
      id = case model_or_id_or_code
        when Currency then model_or_id_or_code.id
        when String, Symbol then Currency.where(code: model_or_id_or_code).pluck(:id).first
        else model_or_id_or_code
      end
      where(currency_id: id)
    end
  end
end
