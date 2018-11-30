# frozen_string_literal: true

# {Operation} provides generic methods for the accounting operations
# models.
# @abstract
class Operation < ActiveRecord::Base
  belongs_to :reference, polymorphic: true
  belongs_to :currency, foreign_key: :currency_id

  validates :credit, :debit, numericality: { greater_than_or_equal_to: 0 }

  self.abstract_class = true

  class << self
    def operation_type
      name.demodulize.downcase.to_sym
    end

    def credit!(reference:, amount:, kind: :main, currency: nil)
      return if amount.zero?

      currency ||= reference.currency
      account_code = Operations::Chart.code_for(
        type:          operation_type,
        kind:          kind,
        currency_type: currency.type.to_sym
      )
      create!(
        credit:      amount,
        reference:   reference,
        currency_id: currency.id,
        code:        account_code
      )
    end

    def debit!(reference:, amount:, kind: :main, currency: nil)
      return if amount.zero?

      currency ||= reference.currency
      account_code = Operations::Chart.code_for(
        type:          operation_type,
        kind:          kind,
        currency_type: currency.type.to_sym
      )
      create!(
        debit:       amount,
        reference:   reference,
        currency_id: currency.id,
        code:        account_code
      )
    end

    def balance(currency: nil, created_at_from: nil, created_at_to: nil)
      if currency.blank?
        db_balances = all
        db_balances = db_balances.where('created_at > ?', created_at_from) if created_at_from.present?
        db_balances = db_balances.where('created_at < ?', created_at_to) if created_at_to.present?
        db_balances = db_balances.group(:currency_id)
                                 .sum('credit - debit')

        Currency.ids.map(&:to_sym).each_with_object({}) do |id, memo|
          memo[id] = db_balances[id.to_s] || 0
        end
      else
        where(currency: currency).sum('credit - debit')
      end
    end
  end
end
