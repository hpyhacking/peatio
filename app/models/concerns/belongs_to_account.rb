# encoding: UTF-8
# frozen_string_literal: true

module BelongsToAccount
  extend ActiveSupport::Concern

  included do
    belongs_to :account, required: true
    validate do
      if try(:currency) && account && account.currency != currency
        errors.add(:currency, :invalid)
        errors.add(:account, :invalid)
      end
    end
  end
end
